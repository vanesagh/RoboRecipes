

*** Settings ***
Library     Dialogs
Library     Browser
Library     OperatingSystem
Library     Browser
Library     SeleniumLibrary
Library     Dialogs
Library     Collections
Library     String
Library     JSONLibrary
Resource    ChainBakerKeywords.resource

*** Variables ***
${KingArthurURL}=    https://www.kingarthurbaking.com
&{websites_dict}
...     Chain Baker=https://www.chainbaker.com/?s=
...     King Arthur=${KingArthurURL}/search?query=

${Chain Baker recipes selector}=    h2
${Chain Baker ingredients selector}=    .et_pb_text_2
${King Arthur recipes selector}=    div.hits.grid--3-col div.grid__item.recipe--grid-item
${King Arthur ingredients selector}=    .ingredients-list




*** Keywords ***
Ask User For Recipe
    ${recipe}=    Get Value From User    What recipe are you looking for?
    Log    ${recipe}
    RETURN    ${recipe}

Ask User for Websites To Search In
    @{websites}=    Get Selections From User   Select websites     Chain Baker    King Arthur
    RETURN    ${websites}

Open Page To Search For A Recipe
    [Arguments]    ${recipe}    ${website}
    New Browser
    ...    browser=Chromium
    ...    headless=False
    Set Browser Timeout    2m

    IF    '${website}' == 'Chain Baker'
        New Page    ${websites_dict}[${website}]${recipe}
    ELSE IF    '${website}' == 'King Arthur'
        New Page    ${websites_dict}[${website}]${recipe}#recipe_index
    ELSE
        New Page    ${website}
    END




Get Search Results
    [Arguments]    ${website}
    ${results}=    Browser.Get Element Count    h2.not-found-title
    IF    ${results} != ${0}
        ${choice}=    Get Value From User    Recipe not found. Search again?    Y/N
        IF    ${choice}== Y
            ${recipe}=    Ask User For Recipe
            ${websites}=    Ask User for Websites To Search In
            Open Page To Search For A Recipe    ${recipe}    ${website}
            Get Search Results    ${website}
        END
        IF    ${choice} == N    [Teardown]    Close Browser
    ELSE

         IF    '${website}' == 'Chain Baker'
             ${selector}=   Set Variable    ${Chain Baker recipes selector}
             Log    ${selector}
         ELSE
             ${selector}=    Set Variable    ${King Arthur recipes selector}
             Log    ${selector}
         END


        ${url}=    Select From Different Recipes Found    ${selector}
        ${element}    ${recipe_name}=    Go To Selected Recipe    ${url}    ${website}
        IF    '${website}' == 'Chain Baker'
            ${dict_ingredients}=    Get Ingredients From ChainBaker    ${element}
        ELSE
            ${dict_ingredients}=    Get Ingredients From KingArthur    ${element}
        END

    END

    #RETURN    ${dict_ingredients}    ${recipe_name}

Get All Recipes Found
    [Arguments]    ${selector}
    ${elements}=    Browser.Get Elements    ${selector}
    ${recipes}=    Create List
    ${recipe_href_dict}=    Create Dictionary
    FOR    ${elem}    IN    @{elements}
        ${recipe}=    Browser.Get Property    ${elem}    innerText
        ${href}=    Browser.Get Element    ${elem}>a[href]
        ${href}=    Browser.Get Attribute    ${href}    href
        Set To Dictionary    ${recipe_href_dict}    ${recipe}    ${href}
        Append To List    ${recipes}    ${recipe}
    END
    RETURN    ${recipes}    ${recipe_href_dict}

Select From Different Recipes Found
    [Arguments]    ${selector}
    ${recipes}    ${dict}=    Get All Recipes Found    ${selector}
    ${selected_recipe}=    Get Selection From User    Recipes Found    @{recipes}
    ${url}=    Get From Dictionary    ${dict}    ${selected_recipe}
    RETURN    ${url}

Go To Selected Recipe
    [Arguments]    ${url}    ${website}

    Browser.Set Browser Timeout    2m 30 seconds
    IF    '${website}' == 'King Arthur'
        Browser.Go To    ${KingArthurURL}${url}
        ${element}=    Browser.Get Element    ${King Arthur ingredients selector}
        Log    ${KingArthurURL}${url}
    ELSE
        Browser.Go To    ${url}
        ${element}=    Browser.Get Element    ${Chain Baker ingredients selector}

    END
    ${recipe_name}=    Browser.Get Element    h1
    ${recipe_name}=    Browser.Get Text    ${recipe_name}
    RETURN    ${element}    ${recipe_name}

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

Find Units In Grams
    [Arguments]    ${ingredient}
    ${grams_unit}=    Get Regexp Matches    ${ingredient}    [0-9]{1,4}g
    ${len_grams_unit}=    Get Length    ${grams_unit}
    RETURN    ${len_grams_unit}    ${grams_unit}

Get Units In Grams
    [Arguments]    ${grams_unit}
    ${quantity}=    Get Substring    ${grams_unit}[0]    0    -1
    ${units}=    Get Substring    ${grams_unit}[0]    -1
    RETURN    ${units}    ${quantity}

Find Ingredients by Quantity
    [Arguments]    ${ingredient}
    ${quantity}=    Get Regexp Matches    ${ingredient}    ^[0-9]{1,4}
    ${len_quantity}=    Get Length    ${quantity}
    RETURN   ${len_quantity}    ${quantity}

Get Ingredients by Quantity
    [Arguments]    ${ingredient}
    ${ingredient_wo_unit}=    Remove String Using Regexp    ${ingredient}    ^[0-9]{1,4}
    ${quantity}=    Get Regexp Matches    ${ingredient}    ^[0-9]{1,4}
    RETURN    ${quantity}    ${ingredient_wo_unit}


Get Item For Units In Grams
    [Arguments]    ${ingredient}
    ${item}=    Remove String Using Regexp    ${ingredient}    ([1-9 \/]+)(cup|tablespoon|teaspoon)s?\\s*\\(.*\\)\\s*
    RETURN    ${item}

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

    FOR    ${ingredient}   IN    @{ingredients}
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
                ${item}=    Get Item For Units In Grams    ${ingredient}
                ${dict_ing}=    Create Dictionary
                ...    item=${item}    quantity (g)=${quantity_g}    units in g=${units_g}
                ...    quantity (cups,spoons)=${quantity}    units in cups,spoons=${units}

            ELSE IF    ${len_grams_unit} == ${0} and ${len_cups_unit} == ${1}
                ${units}    ${quanity}=    Get Units In Cups Teaspoons Or Tablespoons    ${cups_un
            ELSE IF    ${len_quantity} == ${1}
                 Get Ingredients by Quantity    ${ingredient}
            ELSE
                Log    ${ingredient}
            END
            RETURN    ${dict_ing}



            Append To List    ${list_ingredients}    ${ingredient}
        END
        Log     ${list_ingredients}
        Append To List    ${list_of_list}    ${list_ingredients}
    END
    FOR    ${process_name}    ${list_ingredients}    IN ZIP    ${list_processes}    ${list_of_list}
        Set To Dictionary    ${dict_ingredients}    ${process_name}=${list_ingredients}
    END
    Log    ${dict_ingredients}
    RETURN    ${dict_ingredients}

    # to do:  when there's no process




Save Results To JSON File
    [Arguments]    ${dict_ingredients}    ${recipe_name}
    Dump Json To File    ${recipe_name}_ingredients.json    ${dict_ingredients}
