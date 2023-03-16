*** Settings ***
Resource    keywords.resource


*** Tasks ***
Search For A Recipe
    ${recipe}=    Ask User For Recipe
    ${websites}=    Ask User for Websites To Search In
    Search In Different Recipe Websites    ${recipe}    ${websites}    #Chain Baker and King Arthur for now




*** Keywords ***

Search In Different Recipe Websites
    [Arguments]    ${recipe}    ${websites}
    FOR    ${website}    IN    @{websites}
        Open Page To Search For A Recipe    ${recipe}    ${website}
        ${results}    ${recipe_name}=    Get Search Results    ${website}
        Save Results To JSON File    ${results}    ${recipe_name}

    END
    Log    ${websites}
    Log    ${recipe}




