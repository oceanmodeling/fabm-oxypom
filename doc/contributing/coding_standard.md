<!--
SPDX-FileContributor: Carsten Lemmen <carsten.lemmen@hereon.de>
SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
SPDX-License-Identifier: CC0-1.0
-->

# Coding standard

We hope you find it easy to read our code and understand its structure. When you contribute code to our project, we ask you to adhere to coding standards, the most important one is consistency with the current code.

## Coding rules

1. Consistency
   : Whatever you do, be consistent in what you do. This is the guiding principle all other rules are subjected to

2. Line break
   : Please break at 132 columns at the latest

3. Empty lines.
   : Do not overuse empty lines, but reserve them for separating logical units or blocks of statements, just like
   you would use paragraphs in a text. Separate procedures with one empty line.

4. Indentation
   Use consistent and logical indentation to make the code more readable. Each level of indentation should consist of three spaces.

5. Naming conventions
   : Use meaningful english names for variables, procedures, and functions. Names should be descriptive and use lowercase letters.

6. Comments:
   : Use comments to explain complex sections of code, as well as to provide an overview of what the code does. 

7. Error handling:
   Always include error handling code to catch and handle unexpected exceptions. Preferably either halt the simulation with `stop`. Use appropriate error messages to help users diagnose and fix problems.

8. Documentation:
    Provide documentation for the code, including a description of its purpose, its input and output parameters, and examples of its usage.
