*** Settings ***
Library    Browser
Library    Collections
Library    String
Resource   keywords.resource


*** Keywords ***
Get Ingredients From KingArthur
    [Arguments]    ${element}

    ${processes_names}=    Browser.Get Elements    ${element}>.ingredient-section>p
    ${ingredients}=    Browser.Get Elements    ${element}>.ingredient-section>.list--bullets
    ${list_processes}=     Create List
    ${list_of_list}=    Create List
    ${dict_ingredients}=    Create Dictionary

    FOR    ${process_name}    IN    @{processes_names}
        ${process_name}=    Browser.Get Text   ${process_name}
        Append To List    ${list_processes}    ${process_name}
    END
    Log    ${list_processes}

    FOR    ${ingredient}       IN    @{ingredients}
        ${list_ingredients}=    Create List
        ${ingredients_process}=    Browser.Get Elements    ${ingredient}>li

        FOR    ${ingredient}    IN    @{ingredients_process}
            ${ingredient}=    Browser.Get Text    ${ingredient}
            ${len_grams_unit}    ${grams_unit}=    Find Units In Grams    ${ingredient}
            ${len_cups_unit}    ${cups_unit}=    Find Units In Cups Teaspoons Or Tablespoons    ${ingredient}
            ${len_quantity}    ${quantity}=    Find Ingredients by Quantity    ${ingredient}
            ${len_other_opt}=    Find Other Options in Ingredient    ${ingredient}

            IF    ${len_other_opt} == ${1}
                Get Other Options in Ingredient    ${ingredient}
            ELSE IF    ${len_grams_unit} == ${1} and ${len_cups_unit} == ${1}
                ${units_g}    ${quantity_g}=    Get Units In Grams    ${grams_unit}
                ${units}    ${quantity}=    Get Units In Cups Teaspoons Or Tablespoons    ${cups_unit}
                ${item}=    Get Item    ${ingredient}    ([1-9 \/]+)(cup|tablespoon|teaspoon)s?\\s*\\(.*\\)\\s*
                ${dict_ing}=    Create Dictionary
                ...    item=${item}    quantity (g)=${quantity_g}    units in g=${units_g}
                ...    quantity (cups,spoons)=${quantity}    units in cups,spoons=${units}
                Append To List    ${list_ingredients}    ${dict_ing}

            ELSE IF    ${len_grams_unit} == ${0} and ${len_cups_unit} == ${1}
                ${units}    ${quantity}=    Get Units In Cups Teaspoons Or Tablespoons    ${cups_unit}
                ${item}=    Get Item    ${ingredient}    ([1-9 \/]+)(cup|tablespoon|teaspoon)s?
                ${dict_ing}=    Create Dictionary
                ...    item=${item}    quantity (cups,spoons)=${quantity}    units in cups,spoons=${units}
                Append To List    ${list_ingredients}    ${dict_ing}
            ELSE IF    ${len_quantity} == ${1}
                 ${quantity}    ${item}=    Get Ingredients by Quantity    ${ingredient}
                 ${dict_ing}=    Create Dictionary
                 ...    item=${item}    quantity (cups,spoons)=${quantity}[0]
                 Append To List    ${list_ingredients}    ${dict_ing}
            ELSE
                Log    ${ingredient}
            END
        END
        #Log     ${list_ingredients}
        Set To Dictionary    ${dict_ingredients}    ${list_processes}[${i}]=${list_ingredients}
        ${i}=    Evaluate    ${i}+1
    END
    #Log    ${dict_ingredients}
    RETURN    ${dict_ingredients}

    # TO DO:  when there's no process


Find Other Options in Ingredient
    [Arguments]    ${ingredient}
    ${other_options}=    Get Regexp Matches    ${ingredient}      ${SPACE}(or|OR) \\d
    ${len_other_options}=    Get Length    ${other_options}
    RETURN    ${len_other_options}

Get Other Options in Ingredient
    [Arguments]    ${ingredient}
    ${ingredient}=    Convert To Lower Case    ${ingredient}
    @{other_options}=    Split String    ${ingredient}    ${SPACE}or${SPACE}
    #${dict_ing}=    Create Dictionary    item=${ingredient}    quantity=${quantity}[0]
    #RETURN    ${dict_ing}

Find Units In Cups Teaspoons Or Tablespoons
    [Arguments]    ${ingredient}
    ${cups_unit}=    Get Regexp Matches    ${ingredient}    ([1-9 \/+]+) (cup|tablespoon|teaspoon)s?
    ${len_cups_unit}=    Get Length    ${cups_unit}
    RETURN    ${len_cups_unit}    ${cups_unit}


Get Units In Cups Teaspoons Or Tablespoons
    [Arguments]    ${cups_unit}
    ${units}=    Remove String Using Regexp    ${cups_unit}[0]    ([1-9 \/]+)
    ${quantity}=    Remove String Using Regexp    ${cups_unit}[0]    (cup|tablespoon|teaspoon)s?
    RETURN    ${units}    ${quantity}

Find Ingredients by Quantity
    [Arguments]    ${ingredient}
    ${quantity}=    Get Regexp Matches    ${ingredient}    ^[0-9]{1,4}
    ${len_quantity}=    Get Length    ${quantity}
    RETURN   ${len_quantity}    ${quantity}

Get Ingredients by Quantity
    [Arguments]    ${ingredient}
    ${item}=    Remove String Using Regexp    ${ingredient}    ^[0-9]{1,4}
    ${quantity}=    Get Regexp Matches    ${ingredient}    ^[0-9]{1,4}
    RETURN    ${quantity}    ${item}



