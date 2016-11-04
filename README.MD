# Pantry | Calories Counter

Pantry is a calorie counting app that assists those interested in fitness to reach their desired goals in performance and body composition.

## Problem / Goal

The goal of this app was give the users the ability to easily count their calories for the day. It would provide them with a rich database of existing foods with the ability to add their own. Calorie logs would be daily and users can switch between days easily. Each day would provide them a macronutrient breakdown of their calories.

## Approach

1. Get the relationships right
2. Build the back end logic for all functionality with a dummy UI
3. Flesh out the functionality more
4. Build a real UI around the functioanlity built
5. Input validation via models

## Challenges Faced

The biggest initial challenge was the lack of an existing rich database of food for the user to use. They would have to manualy add every food initially until the database was built and established. I decided to look into an existing database of food at MyFitnessPal, a calorie counter I've used daily for years. There was no readily available API and so I then looked to another solution that involved 'scraping their database using a gem a called Nokigiri.

Calorie counting maths isn't complicated but it's tedious when it needs to tracked per day and based on macronutrient breakdown. Ensuring the users actions obeyed the rules of the database relationships was hard. ie. The user has many diary entries. A food can belong to many entries. Ensuring this logic was in tact was tricky.

A fluid and responsive UI. I wanted the UI to be simple enough for a user to quickly add a food and keep going with their day. Building a UI that encouraged this was tough and required a lot of trial and error. Bootstrap was used to allow the app to be used on a phone.

Bootstrap modals. While these are great for getting some quick input from the user, there was a problem in giving the modal access to the object in question. When building out a list with Ruby each item had a modal specific to that item to allow it to be added to the diary or edited. The problem is whenever a modal is invoked the data in the loop is not accessible. Addressing this required jquery and injecting data into the modal.

## Tech Used

Ruby, JavaSCript, HTML5, CSS, jQuery & Boostrap

Ruby Gems:
- sinatra
- httparty
- nokogiri
- pry

## Going Foward

* Build search
* Users frequently added foods
* Grocery lists based on consumption
