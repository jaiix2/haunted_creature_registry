# Pixel Raiders Gaming Club Signup

A polished Flutter demo for a gaming club signup form. It includes client-side name, email, and password validation, controller disposal, success feedback, and an offline `password help` signup tip simulation.



## Undergraduate reflection

Question 1: Trace the local tip feature from button tap to displayed text. Which widget/state changes during the simulated loading state, and how does the user recover from the local error case?

Answer:
When the user presses the signup-tip button, it calls `requestTip()`, which changes `_tipStatus` to loading and updates the `_TipCard` to show a loading indicator. After a small delay, the app either displays a preset tip or shows a simulated error on the first attempt. If an error happens, the user can press retry, which runs the request again and displays a tip.


Question 3: Trace the local tip feature from button tap to displayed text. Which widget/state changes during the simulated loading state, and how does the user recover from the local error case?

Answer:
The app uses a fixed category called `password_help`, which selects from a list of preset password tips stored in the code. The feature doesn't use any information entered in the signup form- including the user's name, email, or password. This keeps personal information private and makes sure the tip feature stays separate from the actual signup validation.



# Completed Task A





# Created by Jalen Artis
