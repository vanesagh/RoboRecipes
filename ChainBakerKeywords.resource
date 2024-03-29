*** Settings ***
Library    Browser
Library    Collections
Library    String
Resource    keywords.resource


*** Keywords ***
Get Ingredients From ChainBaker
    [Arguments]    ${element}
    ${ingredients}=    Browser.Get Elements    ${element}>p
    ${list_ingredients}=    Create List
    ${dict_ingredients}=    Create Dictionary

    FOR    ${ingredient}    IN    @{ingredients}
        ${text}=    Browser.Get Text    ${ingredient}
        ${len_text}=    Get Length    ${text}
        # Find text with ingredients with units
        ${len_ing_w_units}    ${grams_unit}=    Find Units In Grams    ${text}
        # Find text with ingredients without units
        ${ing_wo_units}=    Get Regexp Matches    ${text}    ^[0-9]{1,4}
        ${len_ing_wo_units}=    Get Length    ${ing_wo_units}
        # Find steps of the recipe process
        ${process_3}=    Get Substring    ${text}    0    3
        Log    ${process_3}
        IF    $process_3 == "To " or $process_3=="For"
            ${process}=    Get Substring    ${text}    0    -1
        ELSE IF    ${len_text}==${1}
            Set To Dictionary    ${dict_ingredients}    ${process}=${list_ingredients}
            ${list_ingredients}=    Create List
            Log    ${dict_ingredients}
        ELSE IF    ${len_ing_w_units}!= ${0}
            ${dict_ing}=    Get Ingredient With Units    ${text}    ${grams_unit}
            Append To List    ${list_ingredients}    ${dict_ing}
        ELSE IF    ${len_ing_wo_units}!=${0}
            ${dict_ing}=    Get Ingredient Without Units    ${text}
            Append To List    ${list_ingredients}    ${dict_ing}
        ELSE
            Get Other Ingredients    ${list_ingredients}    ${text}
        END
    END
    ${dict_keys}=    Get Dictionary Keys    ${dict_ingredients}
    ${index_key}=    Get Index From List    ${dict_keys}    ${process}
    IF    "${index_key}" != "${-1}"
        #Log    ${dict_ingredients}[${process}]
        FOR    ${ingredient}    IN    @{list_ingredients}
            Append To List    ${dict_ingredients}[${process}]    ${ingredient}
        END
        Log    ${dict_ingredients}
    ELSE
        #Log    ${process}
        Set To Dictionary    ${dict_ingredients}    ${process}=${list_ingredients}
    END
    Log    ${dict_ingredients}
    RETURN    ${dict_ingredients}

Get Ingredient With Units
    [Arguments]    ${text}    ${grams_unit}
    ${units}    ${quantity}=  Get Units In Grams    ${grams_unit}
    ${item}=    Get Item    ${text}    [0-9]{1,4}g\\s*\\(.*oz\\)
    ${dict_ing}=    Create Dictionary    item=${item}    quantity=${quantity}    units=${units}
    RETURN    ${dict_ing}

Get Ingredient Without Units
    [Arguments]    ${text}
    ${ingredient}=    Remove String Using Regexp    ${text}    ^[0-9]{1,4}
    ${quantity}=    Get Regexp Matches    ${text}    ^[0-9]{1,4}
    ${dict_ing}=    Create Dictionary    item=${ingredient}    quantity=${quantity}[0]
    RETURN    ${dict_ing}

Get Other Ingredients
    [Arguments]    ${list_ingredients}    ${text}
    ${dict_other}=    Create Dictionary    item=${text}
    Append To List    ${list_ingredients}    ${dict_other}

