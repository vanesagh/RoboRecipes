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
    Get Search Results


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

Get Search Results
    ${results}=    Browser.Get Element Count    h2.not-found-title
    IF    ${results} != ${0}
        ${choice}=    Get Value From User    Recipe found. Search again?    Y/N
        IF    ${choice}== Y
            ${recipe}=    Ask User For Recipe
            Open Page To Search For A Recipe    ${recipe}
            Get Search Results
        END
        IF    ${choice} == N    [Teardown]    Close Browser
    ELSE
        ${url}=    Select From Different Recipes Found
        ${element}=    Go To Selected Recipe    ${url}
        Get Ingredients    ${element}
    END

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
    ${dict_ingredients}=    Create Dictionary
    #Create File    ${OUTPUT_DIR}/r.json    {"ingredients":[]}
    #${json}=    Load JSON From File    ${OUTPUT_DIR}/r.json

    FOR    ${ingredient}    IN    @{ingredients}
        ${text}=    Browser.Get Text    ${ingredient}
        ${len_text}=    Get Length    ${text}

        # Find text with ingredients with units
        ${ing_w_units}=    Get Regexp Matches    ${text}    [0-9]{1,4}g
        ${len_ing_w_units}=    Get Length    ${ing_w_units}

        # Find text with ingredients without units
        ${ing_wo_units}=    Get Regexp Matches    ${text}    [0-9]{1,4}
        ${len_ing_wo_units}=    Get Length    ${ing_wo_units}

        # Find steps of the recipe process
        ${process_3}=    Get Substring    ${text}    0    3

        IF    $process_3 == "For"
            ${process}=    Get Substring    ${text}    0    -1
            #&{d}=    Create Dictionary
        ELSE IF    ${len_text}==${1}
            Set To Dictionary    ${dict_ingredients}    ${process}=${list_ingredients}
            ${list_ingredients}=    Create List
            Log    ${dict_ingredients}
        ELSE IF    ${len_ing_w_units}!= ${0}
            ${quantity_w_units}=    Get Regexp Matches    ${text}    [0-9]{1,4}g
            ${quantity}=    Get Substring    ${quantity_w_units}[0]    0    -1
            ${units}=    Get Substring    ${quantity_w_units}[0]    -1

            ${item_wo_oz}=    Remove String Using Regexp
            ...    ${text}
            ...    [(][0-9]{1,4}[.][0-9]{1,4}oz[)]
            ${item}=    Remove String Using Regexp    ${item_wo_oz}    [0-9]{1,4}g
            ${item}=    Get Substring    ${item}    2
            ${dict_ing}=    Create Dictionary    item=${item}    quantity=${quantity}    units=${units}
            Append To List    ${list_ingredients}    ${dict_ing}
        ELSE IF    ${len_ing_wo_units}!=${0}
            ${ingredient}=    Remove String Using Regexp    ${text}    [0-9]{1,4}
            ${quantity}=    Remove String Using Regexp    ${text}    [^0-9]{1,4}
            ${dict_ing}=    Create Dictionary    item=${ingredient}    quantity=${quantity}
            Append To List    ${list_ingredients}    ${dict_ing}
        ELSE
            Log    rest of text
        END
        #Dump Json To File    ${OUTPUT_DIR}/r.json    ${dict_ingredients}
    END
    Set To Dictionary    ${dict_ingredients}    ${process}=@{list_ingredients}

    Log    ${dict_ingredients}
