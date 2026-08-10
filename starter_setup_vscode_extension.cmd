@echo off
SETLOCAL EnableDelayedExpansion

:: Jump directly to the execution entry point at the bottom of the script
goto :MAIN_PIPELINE


:: =========================================================
:: SUBROUTINES SECTION
:: =========================================================

:: =========================================================
:: SUBROUTINE: CHECK_PREREQUISITES
:: Purpose:
::   Verifies that Node.js, NPM, and Git are available in PATH
::   before starting folder creation or file generation.
:: =========================================================
:CHECK_PREREQUISITES
echo =======================================================
echo STEP 1/7: Checking Environment Prerequisites
echo =======================================================

:: 1. Check Node existence
where node >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js is not installed or not available in system PATH.
    echo Please install Node.js ^(v18 or higher^) from https://nodejs.org/
    exit /b 1
)

:: 2. Check NPM existence
where npm >nul 2>&1
if errorlevel 1 (
    echo [ERROR] NPM is not installed or not available in system PATH.
    echo Please ensure NPM is installed alongside Node.js.
    exit /b 1
)

echo [+] Node.js environment detected successfully.
echo.
echo Checking installed versions:
echo -------------------------------------------------------
node -v
call npm -v
echo -------------------------------------------------------
echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: PROMPT_USER_INPUT
:: Purpose:
::   Interactively prompts the user for a VS Code Extension name
::   and publisher name required for marketplace publishing.
:: =========================================================
:PROMPT_USER_INPUT
echo =======================================================
echo STEP 2/7: Prompting Setup Parameters
echo =======================================================

set /p RAW_PROJECT_NAME="Enter your extension name (e.g., my-vscode-extension): "

if "%RAW_PROJECT_NAME%"=="" (
    echo [ERROR] Extension name cannot be empty.
    exit /b 1
)

:: Convert underscores to hyphens for VS Code extension manifest compliance
set RAW_PROJECT_NAME=%RAW_PROJECT_NAME:_=-%

set /p PUBLISHER_NAME="Enter your publisher ID (or press Enter for default 'local-dev'): "
if "%PUBLISHER_NAME%"=="" set PUBLISHER_NAME=local-dev

echo.
echo Project Setup Parameters:
echo   Extension Name: %RAW_PROJECT_NAME%
echo   Publisher ID:   %PUBLISHER_NAME%
echo   Source Dir:     %RAW_PROJECT_NAME%\src
echo =======================================================
echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: CREATE_PROJECT_DIR
:: Purpose:
::   Creates the extension directory structure following modern
::   VS Code architecture conventions.
:: =========================================================
:CREATE_PROJECT_DIR
echo =======================================================
echo STEP 3/7: Creating Directory Structure
echo =======================================================
if NOT EXIST "%RAW_PROJECT_NAME%" (
    mkdir "%RAW_PROJECT_NAME%"
    if errorlevel 1 (
        echo [ERROR] Failed to create directory '%RAW_PROJECT_NAME%'. Check folder permissions.
        exit /b 1
    )
)

cd "%RAW_PROJECT_NAME%"
if errorlevel 1 (
    echo [ERROR] Failed to navigate into '%RAW_PROJECT_NAME%'.
    exit /b 1
)

mkdir "src"
mkdir "src\test"
mkdir ".vscode"

echo [+] Directory structure created successfully.
echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: GENERATE_FILES
:: Purpose:
::   Writes all project configuration files, package manifest,
::   build scripts, formatters, tests, and starter source code.
:: =========================================================
:GENERATE_FILES
echo =======================================================
echo STEP 4/7: Generating Configuration ^& Source Files
echo =======================================================

echo [CMD] Writing package.json manifest...
echo [CMD] Writing package.json manifest...
> package.json echo {
>> package.json echo   "name": "%RAW_PROJECT_NAME%",
>> package.json echo   "displayName": "%RAW_PROJECT_NAME%",
>> package.json echo   "description": "VS Code Extension created with modern build tooling.",
>> package.json echo   "version": "0.0.1",
>> package.json echo   "publisher": "%PUBLISHER_NAME%",
>> package.json echo   "engines": {
>> package.json echo     "vscode": "^1.90.0"
>> package.json echo   },
>> package.json echo   "categories": ["Other"],
>> package.json echo   "activationEvents": [],
>> package.json echo   "main": "./dist/extension.js",
>> package.json echo   "contributes": {
>> package.json echo     "commands": [
>> package.json echo       {
>> package.json echo         "command": "%RAW_PROJECT_NAME%.helloWorld",
>> package.json echo         "category": "%RAW_PROJECT_NAME%",
>> package.json echo         "title": "Hello World"
>> package.json echo       }
>> package.json echo     ]
>> package.json echo   },
>> package.json echo   "scripts": {
>> package.json echo     "vscode:prepublish": "npm run package",
>> package.json echo     "compile": "node esbuild.js",
>> package.json echo     "watch": "node esbuild.js --watch",
>> package.json echo     "package": "node esbuild.js --production",
>> package.json echo     "lint": "eslint src",
>> package.json echo     "format": "prettier --write \"src/**/*.ts\"",
>> package.json echo     "test": "vscode-test",
>> package.json echo     "build:vsix": "vsce package --allow-missing-repository",
>> package.json echo     "install:local": "npm run build:vsix ^&^& code --install-extension %RAW_PROJECT_NAME%-0.0.1.vsix --force"
>> package.json echo   }
>> package.json echo }

echo [CMD] Writing tsconfig.json...
> tsconfig.json echo {
>> tsconfig.json echo   "compilerOptions": {
>> tsconfig.json echo     "module": "NodeNext",
>> tsconfig.json echo     "moduleResolution": "NodeNext",
>> tsconfig.json echo     "target": "ES2022",
>> tsconfig.json echo     "outDir": "dist",
>> tsconfig.json echo     "lib": ["ES2022"],
>> tsconfig.json echo     "sourceMap": true,
>> tsconfig.json echo     "strict": true
>> tsconfig.json echo   },
>> tsconfig.json echo   "exclude": ["node_modules", "dist"]
>> tsconfig.json echo }

echo [CMD] Writing esbuild.js bundler script...
> esbuild.js echo const esbuild = require('esbuild');
>> esbuild.js echo const production = process.argv.includes('--production');
>> esbuild.js echo const watch = process.argv.includes('--watch');
>> esbuild.js echo async function main() {
>> esbuild.js echo   const ctx = await esbuild.context({
>> esbuild.js echo     entryPoints: ['src/extension.ts'],
>> esbuild.js echo     bundle: true,
>> esbuild.js echo     format: 'cjs',
>> esbuild.js echo     minify: production,
>> esbuild.js echo     sourcemap: !production,
>> esbuild.js echo     sourcesContent: false,
>> esbuild.js echo     platform: 'node',
>> esbuild.js echo     outfile: 'dist/extension.js',
>> esbuild.js echo     external: ['vscode']
>> esbuild.js echo   });
>> esbuild.js echo   if (watch) { await ctx.watch(); } else { await ctx.rebuild(); await ctx.dispose(); }
>> esbuild.js echo }
>> esbuild.js echo main().catch(e =^> { console.error(e); process.exit(1); });

echo [CMD] Writing Prettier ^& ESLint configs...
> .prettierrc echo {
>> .prettierrc echo   "semi": true,
>> .prettierrc echo   "singleQuote": true,
>> .prettierrc echo   "tabWidth": 2,
>> .prettierrc echo   "trailingComma": "all"
>> .prettierrc echo }

> eslint.config.mjs echo import tseslint from "typescript-eslint";
>> eslint.config.mjs echo export default tseslint.config(
>> eslint.config.mjs echo   ...tseslint.configs.recommended,
>> eslint.config.mjs echo   {
>> eslint.config.mjs echo     files: ["src/**/*.ts"],
>> eslint.config.mjs echo     rules: { "semi": ["error", "always"] }
>> eslint.config.mjs echo   }
>> eslint.config.mjs echo );

echo [CMD] Writing .vscode-test.mjs config...
> .vscode-test.mjs echo import { defineConfig } from '@vscode/test-cli';
>> .vscode-test.mjs echo export default defineConfig({
>> .vscode-test.mjs echo   files: 'dist/test/**/*.test.js',
>> .vscode-test.mjs echo });

echo [CMD] Writing .vscode settings, launch, tasks, and extensions configs...
> .vscode\launch.json echo {
>> .vscode\launch.json echo   "version": "0.2.0",
>> .vscode\launch.json echo   "configurations": [
>> .vscode\launch.json echo     {
>> .vscode\launch.json echo       "name": "Run Extension",
>> .vscode\launch.json echo       "type": "extensionHost",
>> .vscode\launch.json echo       "request": "launch",
>> .vscode\launch.json echo       "args": ["--extensionDevelopmentPath=${workspaceFolder}"],
>> .vscode\launch.json echo       "outFiles": ["${workspaceFolder}/dist/**/*.js"],
>> .vscode\launch.json echo       "preLaunchTask": "npm: compile"
>> .vscode\launch.json echo     }
>> .vscode\launch.json echo   ]
>> .vscode\launch.json echo }

> .vscode\tasks.json echo {
>> .vscode\tasks.json echo   "version": "2.0.0",
>> .vscode\tasks.json echo   "tasks": [
>> .vscode\tasks.json echo     {
>> .vscode\tasks.json echo       "type": "npm",
>> .vscode\tasks.json echo       "script": "compile",
>> .vscode\tasks.json echo       "group": "build",
>> .vscode\tasks.json echo       "problemMatcher": "$tsc"
>> .vscode\tasks.json echo     }
>> .vscode\tasks.json echo   ]
>> .vscode\tasks.json echo }

> .vscode\settings.json echo {
>> .vscode\settings.json echo   "editor.formatOnSave": true,
>> .vscode\settings.json echo   "editor.defaultFormatter": "esbenp.prettier-vscode",
>> .vscode\settings.json echo   "editor.codeActionsOnSave": {
>> .vscode\settings.json echo     "source.fixAll.eslint": "explicit"
>> .vscode\settings.json echo   },
>> .vscode\settings.json echo   "typescript.tsdk": "node_modules/typescript/lib",
>> .vscode\settings.json echo   "files.eol": "\n"
>> .vscode\settings.json echo }

> .vscode\extensions.json echo {
>> .vscode\extensions.json echo   "recommendations": [
>> .vscode\extensions.json echo     "esbenp.prettier-vscode",
>> .vscode\extensions.json echo     "dbaeumer.vscode-eslint"
>> .vscode\extensions.json echo   ]
>> .vscode\extensions.json echo }

echo [CMD] Writing .vscodeignore and .gitignore...
> .vscodeignore echo .vscode/**
>> .vscodeignore echo src/**
>> .vscodeignore echo node_modules/**
>> .vscodeignore echo .gitignore
>> .vscodeignore echo tsconfig.json
>> .vscodeignore echo esbuild.js
>> .vscodeignore echo ^!dist/extension.js

> .gitignore echo node_modules/
>> .gitignore echo dist/
>> .gitignore echo *.vsix
>> .gitignore echo .vscode-test/

echo [CMD] Writing main extension starter script (src\extension.ts)...
> src\extension.ts echo import * as vscode from 'vscode';
>> src\extension.ts echo.
>> src\extension.ts echo export function activate(context: vscode.ExtensionContext) {
>> src\extension.ts echo   console.log('Extension "%RAW_PROJECT_NAME%" is active!');
>> src\extension.ts echo   let disposable = vscode.commands.registerCommand('%RAW_PROJECT_NAME%.helloWorld', () =^> {
>> src\extension.ts echo     vscode.window.showInformationMessage('Hello World from %RAW_PROJECT_NAME%!');
>> src\extension.ts echo   });
>> src\extension.ts echo   context.subscriptions.push(disposable);
>> src\extension.ts echo }
>> src\extension.ts echo.
>> src\extension.ts echo export function deactivate() {}

echo [CMD] Writing test suite files (src\test\extension.test.ts)...
> src\test\extension.test.ts echo import * as assert from 'assert';
>> src\test\extension.test.ts echo import * as vscode from 'vscode';
>> src\test\extension.test.ts echo.
>> src\test\extension.test.ts echo suite('Extension Test Suite', () =^> {
>> src\test\extension.test.ts echo   vscode.window.showInformationMessage('Running Extension Tests...');
>> src\test\extension.test.ts echo   test('Sample test', () =^> {
>> src\test\extension.test.ts echo     assert.strictEqual(-1, [1, 2, 3].indexOf(5));
>> src\test\extension.test.ts echo     assert.strictEqual(-1, [1, 2, 3].indexOf(0));
>> src\test\extension.test.ts echo   });
>> src\test\extension.test.ts echo });

echo [CMD] Writing README.md workflow instructions...
> README.md echo # %RAW_PROJECT_NAME%
>> README.md echo.
>> README.md echo Modern VS Code Extension built with TypeScript, esbuild, ESLint 9, and Prettier.
>> README.md echo.
>> README.md echo ---
>> README.md echo.
>> README.md echo ## 1. Quick Start ^& Verification ^(How to See It Working^)
>> README.md echo.
>> README.md echo ### Method A: Live Debugging Host ^(Fastest^)
>> README.md echo 1. Open this workspace in VS Code (`code .`).
>> README.md echo 2. Press `F5` ^(or go to `Run and Debug` tab and select `Run Extension`^).
>> README.md echo 3. A new window titled **[Extension Development Host]** will open with this plugin loaded.
>> README.md echo 4. In that new window, press `Ctrl+Shift+P` ^(or `Cmd+Shift+P` on macOS^).
>> README.md echo 5. Run the command: `%RAW_PROJECT_NAME%: Hello World`.
>> README.md echo 6. **Expected Result:** A toast message pops up in the bottom-right corner displaying:
>> README.md echo    `Hello World from %RAW_PROJECT_NAME%!`
>> README.md echo.
>> README.md echo ### Method B: Live Hot-Reloading while Developing
>> README.md echo 1. In your main project terminal, start watch mode:
>> README.md echo ```cmd
>> README.md echo npm run watch
>> README.md echo ```
>> README.md echo 2. Modify code in `src/extension.ts` ^(e.g., change the toast notification text^).
>> README.md echo 3. Switch to the **[Extension Development Host]** window and press `Ctrl+R` ^(or `Cmd+R`^).
>> README.md echo 4. Run `%RAW_PROJECT_NAME%: Hello World` from `Ctrl+Shift+P` to see updates instantly.
>> README.md echo.
>> README.md echo ---
>> README.md echo.
>> README.md echo ## 2. Formatter ^& Linter Setup
>> README.md echo Workspace recommendations are configured in `.vscode/extensions.json`:
>> README.md echo - **Prettier** (`esbenp.prettier-vscode`): Formatting on save is enabled.
>> README.md echo - **ESLint** (`dbaeumer.vscode-eslint`): Fixes lint errors on save.
>> README.md echo.
>> README.md echo Manual CLI Commands:
>> README.md echo ```cmd
>> README.md echo npm run format
>> README.md echo npm run lint
>> README.md echo ```
>> README.md echo.
>> README.md echo ---
>> README.md echo.
>> README.md echo ## 3. Testing
>> README.md echo ```cmd
>> README.md echo npm run test
>> README.md echo ```
>> README.md echo.
>> README.md echo ---
>> README.md echo.
>> README.md echo ## 4. Build, Force-Install, and Update Plugin
>> README.md echo.
>> README.md echo ### Option A: Build VSIX Package Only
>> README.md echo ```cmd
>> README.md echo npm run build:vsix
>> README.md echo ```
>> README.md echo Outputs `%RAW_PROJECT_NAME%-0.0.1.vsix` in the project root.
>> README.md echo.
>> README.md echo ### Option B: Automatic Direct Local Install ^(Force Overwrite^)
>> README.md echo ```cmd
>> README.md echo npm run install:local
>> README.md echo ```
>> README.md echo Automatically packages `.vsix` and force-installs it directly into your local VS Code environment without prompting.
>> README.md echo.
>> README.md echo **Verify Installed Plugin:** Open any standard VS Code window, press `Ctrl+Shift+P`, and run `%RAW_PROJECT_NAME%: Hello World`.
echo [+] Configuration and code starter files generated successfully.

echo [CMD] Writing .vscodeignore and .gitignore...
> .vscodeignore echo .vscode/**
>> .vscodeignore echo src/**
>> .vscodeignore echo node_modules/**
>> .vscodeignore echo .gitignore
>> .vscodeignore echo tsconfig.json
>> .vscodeignore echo esbuild.js
>> .vscodeignore echo eslint.config.mjs
>> .vscodeignore echo .prettierrc
>> .vscodeignore echo .vscode-test.mjs
>> .vscodeignore echo ^^!dist/extension.js

echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: INSTALL_DEPENDENCIES
:: Purpose:
::   Installs modern type definitions, ESLint 9 + TypeScript tooling,
::   and build dependencies without legacy packages or warnings.
:: =========================================================
:INSTALL_DEPENDENCIES
echo =======================================================
echo STEP 5/7: Installing NPM Dependencies
echo =======================================================
echo [INFO] Installing build tools (esbuild, typescript, eslint, prettier)...

call npm install --save-dev @types/vscode@~1.90.0 @types/node typescript esbuild eslint prettier typescript-eslint @vscode/vsce @vscode/test-cli @types/mocha mocha
if errorlevel 1 (
    echo [ERROR] NPM package installation failed.
    echo Please verify your internet connection or NPM proxy settings.
    exit /b 1
)

echo [+] Dependencies installed successfully.
echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: BUILD_INITIAL_BUNDLE
:: Purpose:
::   Compiles TypeScript files via esbuild to generate the initial
::   dist/extension.js file required for debugging.
:: =========================================================
:BUILD_INITIAL_BUNDLE
echo =======================================================
echo STEP 6/7: Compiling Extension Initial Bundle
echo =======================================================

call npm run compile
if errorlevel 1 (
    echo [ERROR] Initial build compilation failed.
    echo Check for TypeScript compilation errors in src/extension.ts.
    exit /b 1
)

echo [+] Initial bundle compiled to dist/extension.js successfully.
echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: INIT_GIT_AND_LAUNCH
:: Purpose:
::   Initializes Git repository and launches VS Code workspace.
:: =========================================================
:INIT_GIT_AND_LAUNCH
echo =======================================================
echo STEP 7/7: Initializing Git ^& Launching Workspace
echo =======================================================

where git >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Git not found in PATH. Skipping Git repository initialization.
) else (
    echo [CMD] Initializing local Git repository...
    git init >nul 2>&1
    git branch -M main >nul 2>&1
    git add .
    git commit -m "Initial commit - VS Code Extension Setup" >nul 2>&1
    echo [+] Git repository initialized on branch 'main'.
)

echo [CMD] Launching VS Code...
call code . >nul 2>&1
if errorlevel 1 (
    echo [WARNING] 'code' command not found in PATH.
    echo Open VS Code manually and select 'File -^> Open Folder' on folder: %CD%
) else (
    echo [+] VS Code launched successfully.
)

echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: ON_ERROR
:: Purpose:
::   Global error handling routine triggered whenever any step fails.
:: =========================================================
:ON_ERROR
echo.
echo =======================================================
echo [FATAL ERROR] Setup pipeline failed.
echo Review the error messages above to locate the exact cause.
echo Common fixes:
echo   1. Ensure Node.js and NPM are installed and added to system PATH.
echo   2. Run command prompt as Administrator if file creation is blocked.
echo =======================================================
pause
exit /b 1


:: =========================================================
:: MAIN EXECUTION PIPELINE
:: =========================================================
:MAIN_PIPELINE

call :CHECK_PREREQUISITES
if errorlevel 1 goto :ON_ERROR

call :PROMPT_USER_INPUT
if errorlevel 1 goto :ON_ERROR

call :CREATE_PROJECT_DIR
if errorlevel 1 goto :ON_ERROR

call :GENERATE_FILES
if errorlevel 1 goto :ON_ERROR

call :INSTALL_DEPENDENCIES
if errorlevel 1 goto :ON_ERROR

call :BUILD_INITIAL_BUNDLE
if errorlevel 1 goto :ON_ERROR

call :INIT_GIT_AND_LAUNCH
if errorlevel 1 goto :ON_ERROR

echo =======================================================
echo SETUP COMPLETE: '%RAW_PROJECT_NAME%' is ready!
echo.
echo Next Steps:
echo   1. In VS Code, press 'F5' to run ^& debug the extension.
echo   2. In the Extension Host window, press Ctrl+Shift+P
echo      and run: %RAW_PROJECT_NAME%: Hello World
echo   3. Follow README.md instructions to build .vsix package.
echo =======================================================
pause
exit /b 0