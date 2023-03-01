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
        Get Search Results    ${website}

    END


    
  


    Log    ${websites}
    Log    ${recipe}




