*** Settings ***
Library     Browser
Library     SeleniumLibrary
Library     Dialogs
Library     Collections



*** Tasks ***
Search For A Recipe
    ${recipe}=      Ask User For Recipe
    Open Page To Search For A Recipe    ${recipe}
    ${url}=     Select From Different Recipes Found
    ${element}=     Go To Selected Recipe   ${url}
    Get Ingredients     ${element}


*** Keywords ***
Ask User For Recipe
    ${recipe}=    Get Value From User    What recipe are you looking for?
    Log     ${recipe}
    RETURN   ${recipe}

Open Page To Search For A Recipe
   [Arguments]     ${recipe}
   New Browser
        ...    browser=Chromium
        ...    headless=False
   Set Browser Timeout    2m
   New Page    https://www.chainbaker.com/?s=${recipe}


Get All Recipes Found
    ${elements}=    Get Elements    h2
    ${recipes}=    Create List
    ${recipe_href_dict}=    Create Dictionary
    FOR    ${elem}     IN  @{elements}
        ${recipe} =    Get Property    ${elem}    innerText
        ${href} =    Get Element    ${elem}>a[href]
        ${href}=       Get Attribute    ${href}    href
        Set To Dictionary    ${recipe_href_dict}    ${recipe}   ${href}
        Append To List    ${recipes}    ${recipe}
    END
    RETURN     ${recipes}    ${recipe_href_dict}


Select From Different Recipes Found
    ${recipes}    ${dict} =     Get All Recipes Found
    ${selected_recipe}=    Get Selection From User    Recipes Found   @{recipes}
    ${url}=     Get From Dictionary    ${dict}    ${selected_recipe}
    RETURN    ${url}

Go To Selected Recipe
    [Arguments]     ${url}
    Set Browser Timeout    2m 30 seconds
    Browser.Go To    ${url}
    ${element}=   Get Element    .et_pb_text_2
    RETURN      ${element}

Get Ingredients
    [Arguments]     ${element}
    ${ingredients}=     Get Elements    ${element}>p
    FOR     ${ingredient}   IN    @{ingredients}
        ${text}=    Browser.Get Text    ${ingredient}
    END



    
