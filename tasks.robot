*** Settings ***
Library     Browser
Library     SeleniumLibrary
Library     Dialogs
Library     Collections



*** Tasks ***
Search For A Recipe
    ${recipe}=      Ask User For Recipe
    Open Page To Search For A Recipe    ${recipe}
    Select From Different Recipes Found



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
   New Page    https://www.chainbaker.com/?s=${recipe}

Get All Recipes Found
    ${elements}=    Get Elements    h2
     ${recipes}=    Create List
     FOR    ${elem}     IN  @{elements}
        ${recipe} =    Get Property    ${elem}    innerText
        ${href} =    Get Element    ${elem}>a[href]
        ${p}=       Get Attribute    ${href}    href
        Append To List    ${recipes}    ${recipe}
     END
     RETURN     ${recipes}


Select From Different Recipes Found
    ${recipes}=     Get All Recipes Found
    ${selected_recipe}=    Get Selection From User    Recipes Found   @{recipes}




    
