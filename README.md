# ROBO RECIPE SCRAPER (2023)
## Introduction

Recently I heard about [RobotFramework](https://robotframework.org/), a framework for test automation and Robotic Process Automation (RPA).
The last one, RPA, I find it pretty cool and super useful, so I decided to give it a try.

I have a small business, a bakery to be more precise. One of the things that I wanted to automate as a first start
is finding the recipes and do the Bill of Materials.

The purpose of this attended robot - yes, it requires a little of human interaction-, **RoboRecipeScraper**, is to search for a recipe in two
specific websites, do scraping in order to get the ingredients
of the recipe, and save it in a json file.

This robot is part of the projects I am developing in 2023. It is still under development although so far it is functional.
I am refactoring some parts of the code for design purposes.

# Use

The logic is straightforward: 
1. A message dialog will pop up, and it will ask you for the **recipe** to search; then
2. The robot will ask you to select which website(s) you want to scrap for the recipe. It could be one of them,
or both. 
3. Another message will pop up with a list of the recipes found. You can select one of them.
4. The robot will do the scraping, and the ingredients will be saved in a json file.




