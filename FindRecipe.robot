*** Settings ***
Library     OperatingSystem
Library     Browser
Library     SeleniumLibrary
Library     Dialogs
Library     Collections
Library     String
Library     JSONLibrary


*** Tasks ***
Search For A Recipe
    ${recipe}=    Ask User For Recipe
    Open Page To Search For A Recipe    ${recipe}
    ${url}=    Select From Different Recipes Found
    ${element}=    Go To Selected Recipe    ${url}
    Get Ingredients    ${element}


*** Keywords ***
Ask User For Recipe
    ${recipe}=    Get Value From User    What recipe are you looking for?
    Log    ${recipe}
    RETURN    ${recipe}

Open Page To Search For A Recipe
    [Arguments]    ${recipe}
    New Browser
    ...    browser=Chromium
    ...    headless=False
    Set Browser Timeout    2m
    New Page    https://www.chainbaker.com/?s=${recipe}

Get All Recipes Found
    ${elements}=    Get Elements    h2
    ${recipes}=    Create List
    ${recipe_href_dict}=    Create Dictionary
    FOR    ${elem}    IN    @{elements}
        ${recipe}=    Get Property    ${elem}    innerText
        ${href}=    Get Element    ${elem}>a[href]
        ${href}=    Get Attribute    ${href}    href
        Set To Dictionary    ${recipe_href_dict}    ${recipe}    ${href}
        Append To List    ${recipes}    ${recipe}
    END
    RETURN    ${recipes}    ${recipe_href_dict}

Select From Different Recipes Found
    ${recipes}    ${dict}=    Get All Recipes Found
    ${selected_recipe}=    Get Selection From User    Recipes Found    @{recipes}
    ${url}=    Get From Dictionary    ${dict}    ${selected_recipe}
    RETURN    ${url}

Go To Selected Recipe
    [Arguments]    ${url}
    Set Browser Timeout    2m 30 seconds
    Browser.Go To    ${url}
    ${element}=    Get Element    .et_pb_text_2
    RETURN    ${element}

Get Ingredients
    [Arguments]    ${element}
    ${ingredients}=    Get Elements    ${element}>p
    ${list_ingredients}=    Create List
    Create File    ${OUTPUT_DIR}/r.json    {"ingredients":[]}
    ${json}=    Load JSON From File    ${OUTPUT_DIR}/r.json

    FOR    ${ingredient}    IN    @{ingredients}
        ${text}=    Browser.Get Text    ${ingredient}
        ${ing}=    Get Regexp Matches    ${text}    [0-9]{1,4}g
        ${len_ing}=    Get Length    ${ing}
        IF    ${len_ing}!= ${0}
            ${i}=    Evaluate    $text.index(")")
            ${integer}=    Convert To Integer    ${i}
            ${i+1}=    Evaluate    ${integer} + ${1}
            ${i+2}=    Evaluate    ${integer} + ${2}
            ${quantity}=    Get Substring    ${text}    ${0}    ${i+1}
            ${ingredient}=    Get Substring    ${text}    ${i+2}
            ${qty_in_g}=    Get Regexp Matches    ${quantity}    [0-9]{1,3}g
            ${len_qty_in_g}=    Get Length    ${qty_in_g}[0]
            ${len_qty-2}=    Evaluate    ${len_qty_in_g}-${2}
            ${quantity}=    Get Substring    ${qty_in_g}[0]    ${0}    ${len_qty-2}
            ${units}=    Get Substring    ${qty_in_g}[0]    -1
            ${dict_ingredients}=    Create Dictionary    item=${ingredient}    quantity=${quantity}    units=${units}
            ${json}=    Add Object To Json    ${json}    $.ingredients    ${dict_ingredients}

            #IF    ')' in '${text}'
            #
            #ELSE
            #    ${i}=    Set Variable    ${None}
            #END
            #IF    '${i}' == 'None'
            #    Log    ${text}
            #ELSE

            #

            #Dump Json To File    ${OUTPUT_DIR}/r.json    ${dict_ingredients}
            #END
        END
    END
