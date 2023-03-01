*** Settings ***
Resource    keywords.resource




*** Tasks ***
Search For A Recipe
    ${recipe}=    Ask User For Recipe
    Open Page To Search For A Recipe    ${recipe}    Chain Baker
    ${results}    ${recipe_name}=    Get Search Results
    Save Results To JSON File    ${results}    ${recipe_name}





