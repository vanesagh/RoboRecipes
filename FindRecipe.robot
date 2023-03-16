*** Settings ***
Resource    keywords.resource




*** Tasks ***
Search For A Recipe
    ${recipe}=    Ask User For Recipe
    Open Page To Search For A Recipe    ${recipe}    https://theviewfromgreatisland.com/#search/q=muffins
    ${g}=    Get Elements    div#slickTemplateCellContainer
    ${results}    ${recipe_name}=    Get Search Results    ${recipe}
    Save Results To JSON File    ${results}    ${recipe_name}





