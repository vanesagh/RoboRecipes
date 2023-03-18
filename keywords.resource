
*** Settings ***
Library     Dialogs
Library     Browser
Library     OperatingSystem
Library     Browser
Library     SeleniumLibrary
Library     Dialogs
Library     Collections
Library     String
Library     JSONLibrary
Resource    ChainBakerKeywords.resource
Resource    KingArthurKeywords.resource

*** Variables ***
${KingArthurURL}=    https://www.kingarthurbaking.com
&{websites_dict}
...     Chain Baker=https://www.chainbaker.com/?s=
...     King Arthur=${KingArthurURL}/search?query=

&{websites_ingredients_selector_dict}
...    Chain Baker=.et_pb_text_2 > div:nth-child(1)
...    King Arthur=.ingredients-list

&{websites_recipes_selector_dict}
...    Chain Baker=h2
...    King Arthur=div.hits.grid--3-col div.grid__item.recipe--grid-item

${i}=    ${0}



*** Keywords ***
Ask User For Recipe
    ${recipe}=    Get Value From User    What recipe are you looking for?
    Log    ${recipe}
    RETURN    ${recipe}

Ask User for Websites To Search In
    @{websites}=    Get Selections From User   Select websites     Chain Baker    King Arthur
    RETURN    ${websites}

Open Page To Search For A Recipe
    [Arguments]    ${recipe}    ${website}
    New Browser
    ...    browser=Chromium
    ...    headless=False
    Set Browser Timeout    2m

    IF    '${website}' == 'Chain Baker'
        New Page    ${websites_dict}[${website}]${recipe}
    ELSE IF    '${website}' == 'King Arthur'
        New Page    ${websites_dict}[${website}]${recipe}#recipe_index
    ELSE
        New Page    ${website}
    END


Handle Recipe Not Found
    [Arguments]    ${website}
    ${choice}=    Get Value From User    Recipe not found. Search again?    Y/N
        IF    '${choice}' == 'Y'
            ${recipe}=    Ask User For Recipe
            ${websites}=    Ask User for Websites To Search In
            Open Page To Search For A Recipe    ${recipe}    ${website}
            ${results}    ${recipe_name}=    Get Search Results    ${website}
            Save Results To JSON File    ${results}    ${recipe_name}
        ELSE
            Browser.Close Browser    CURRENT
        END

Handle Recipe Results
    [Arguments]    ${website}
    ${selector}=   Set Variable    ${websites_recipes_selector_dict}[${website}]
    RETURN    ${selector}


Get Search Results
    [Arguments]    ${website}
    ${not_found_CB}=    Browser.Get Element Count    h2.not-found-title
    ${not_found_KA}=    Browser.Get Element Count    .hits.grid.grid--3-col>h4
    Log Many    ${not_found_CB}    ${not_found_KA}

    IF    ${not_found_CB} != ${0} or ${not_found_KA} != ${0}
        Handle Recipe Not Found    ${website}
        RETURN
    ELSE   
        ${selector}=    Handle Recipe Results    ${website}   
        ${url}=    Select From Different Recipes Found    ${selector}
        ${element}    ${recipe_name}=    Go To Selected Recipe    ${url}    ${website}
        IF    '${website}' == 'Chain Baker'
            ${dict_ingredients}=    Get Ingredients From ChainBaker    ${element}
        ELSE
            ${dict_ingredients}=    Get Ingredients From KingArthur    ${element}
        END
    END
    RETURN    ${dict_ingredients}    ${recipe_name}

Get All Recipes Found
    [Arguments]    ${selector}
    ${elements}=    Browser.Get Elements    ${selector}
    ${recipes}=    Create List
    ${recipe_href_dict}=    Create Dictionary
    FOR    ${elem}    IN    @{elements}
        ${recipe}=    Browser.Get Property    ${elem}    innerText
        ${href}=    Browser.Get Element    ${elem}>a[href]
        ${href}=    Browser.Get Attribute    ${href}    href
        Set To Dictionary    ${recipe_href_dict}    ${recipe}    ${href}
        Append To List    ${recipes}    ${recipe}
    END
    RETURN    ${recipes}    ${recipe_href_dict}

Select From Different Recipes Found
    [Arguments]    ${selector}
    ${recipes}    ${dict}=    Get All Recipes Found    ${selector}
    ${selected_recipe}=    Get Selection From User    Recipes Found    @{recipes}
    ${url}=    Get From Dictionary    ${dict}    ${selected_recipe}
    RETURN    ${url}

Go To Selected Recipe
    [Arguments]    ${url}    ${website}

    Browser.Set Browser Timeout    2m 30 seconds
    IF    '${website}' == 'King Arthur'
        Browser.Go To    ${KingArthurURL}${url}
    ELSE
        Browser.Go To    ${url}
    END
    ${element}=    Browser.Get Element    ${websites_ingredients_selector_dict}[${website}]
    ${recipe_name}=    Browser.Get Element    h1
    ${recipe_name}=    Browser.Get Text    ${recipe_name}
    RETURN    ${element}    ${recipe_name}


Find Units In Grams
    [Arguments]    ${ingredient}
    ${grams_unit}=    Get Regexp Matches    ${ingredient}    [0-9]{1,4}g
    ${len_grams_unit}=    Get Length    ${grams_unit}
    RETURN    ${len_grams_unit}    ${grams_unit}

Get Units In Grams
    [Arguments]    ${grams_unit}
    ${quantity}=    Get Substring    ${grams_unit}[0]    0    -1
    ${units}=    Get Substring    ${grams_unit}[0]    -1
    RETURN    ${units}    ${quantity}


Get Item
    [Arguments]    ${ingredient}    ${regex}
    ${item}=    Remove String Using Regexp    ${ingredient}    ${regex}
    RETURN    ${item}


Save Results To JSON File
    [Arguments]    ${dict_ingredients}    ${recipe_name}
    Dump Json To File    ${recipe_name}_ingredients.json    ${dict_ingredients}
