@echo off
SETLOCAL EnableDelayedExpansion

:: Jump directly to the execution entry point at the bottom of the script
goto :MAIN_PIPELINE


:: =========================================================
:: SUBROUTINES SECTION
:: =========================================================

:: =========================================================
:: SUBROUTINE: PROMPT_USER_INPUT
:: Purpose:
::   Interactively prompts the user for a library/project name.
::   Validates that the input is non-empty and generates a clean
::   Python module name by converting hyphens (-) to underscores (_).
:: Inputs:
::   User text input via console.
:: Outputs:
::   %RAW_PROJECT_NAME% - Directory and PyPI package name (e.g., my-agents-lib)
::   %MODULE_NAME%      - Valid Python import name (e.g., my_agents_lib)
:: =========================================================
:PROMPT_USER_INPUT
echo =======================================================
echo Generic Python Library Setup (src Layout)
echo =======================================================

set /p RAW_PROJECT_NAME="Enter your library name (e.g., my_awesome_lib): "

if "%RAW_PROJECT_NAME%"=="" (
    echo [ERROR] Project name cannot be empty.
    exit /b 1
)

:: Sanitize project name (replace dashes with underscores for Python imports)
set MODULE_NAME=%RAW_PROJECT_NAME:-=_%

echo.
echo Setup Parameters:
echo   Project Name: %RAW_PROJECT_NAME%
echo   Module Name:  %MODULE_NAME%
echo   Source Dir:   %RAW_PROJECT_NAME%\src\%MODULE_NAME%
echo =======================================================
echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: CREATE_PROJECT_DIR
:: Purpose:
::   Creates the primary project root directory and the standard
::   src-layout directory tree required for modern Python packaging.
:: Creates:
::   - %RAW_PROJECT_NAME%/
::   - %RAW_PROJECT_NAME%/src/%MODULE_NAME%/
::   - %RAW_PROJECT_NAME%/tests/
::   - %RAW_PROJECT_NAME%/.vscode/
:: =========================================================
:CREATE_PROJECT_DIR
echo =======================================================
echo STEP 1/7: Creating Directory Structure
echo =======================================================
echo [CMD] IF NOT EXIST "%RAW_PROJECT_NAME%" mkdir "%RAW_PROJECT_NAME%"
IF NOT EXIST "%RAW_PROJECT_NAME%" (
    mkdir "%RAW_PROJECT_NAME%"
    if errorlevel 1 exit /b 1
)

echo [CMD] cd "%RAW_PROJECT_NAME%"
cd "%RAW_PROJECT_NAME%"
if errorlevel 1 exit /b 1

echo [CMD] mkdir "src\%MODULE_NAME%"
mkdir "src\%MODULE_NAME%"
if errorlevel 1 exit /b 1

echo [CMD] mkdir "tests"
mkdir "tests"
if errorlevel 1 exit /b 1

echo [CMD] mkdir ".vscode"
mkdir ".vscode"
if errorlevel 1 exit /b 1

echo [+] Directory structure created successfully.
echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: GENERATE_FILES
:: Purpose:
::   Writes starter template files and a detailed README.md on build,
::   export, and consumer usage instructions.
:: Creates:
::   - src/%MODULE_NAME%/__init__.py : Package marker with version string.
::   - tests/__init__.py             : Test suite package marker.
::   - README.md                      : Detailed developer & user guide.
::   - .gitignore                     : Rules ignoring venv, build artifacts, etc.
::   - pyproject.toml                 : Hatchling build config.
::   - .vscode/settings.json          : Auto-activates virtual environment in VS Code.
::   - build_and_install.cmd          : Script to generate wheels (.whl).
:: =========================================================
:GENERATE_FILES
echo =======================================================
echo STEP 2/7: Generating Project Files
echo =======================================================

echo [CMD] Writing starter Python package markers...
> "src\%MODULE_NAME%\__init__.py" echo __version__ = "0.1.0"
type NUL > "tests\__init__.py"

echo [CMD] Writing README.md with build, import, and usage instructions...
> README.md echo # %RAW_PROJECT_NAME%
>> README.md echo.
>> README.md echo A modular Python library using the standard `src/` layout.
>> README.md echo.
>> README.md echo ---
>> README.md echo.
>> README.md echo ## 1. Local Development
>> README.md echo.
>> README.md echo Activate the virtual environment and install in editable mode:
>> README.md echo ```cmd
>> README.md echo venv\Scripts\activate.bat
>> README.md echo pip install -e .[dev]
>> README.md echo ```
>> README.md echo.
>> README.md echo ---
>> README.md echo.
>> README.md echo ## 2. How to Build and Export the Package
>> README.md echo.
>> README.md echo Run the included build script or execute `python -m build`:
>> README.md echo ```cmd
>> README.md echo build_and_install.cmd
>> README.md echo ```
>> README.md echo This creates distribution packages inside the `dist/` directory:
>> README.md echo - Wheel package: `dist/%MODULE_NAME%-0.1.0-py3-none-any.whl`
>> README.md echo - Source tarball: `dist/%RAW_PROJECT_NAME%-0.1.0.tar.gz`
>> README.md echo.
>> README.md echo ---
>> README.md echo.
>> README.md echo ## 3. How Other Projects Can Use This Library
>> README.md echo.
>> README.md echo ### Option A: Direct Local Path (Best for active development)
>> README.md echo In your consumer application's virtual environment:
>> README.md echo ```cmd
>> README.md echo pip install -e path\to\%RAW_PROJECT_NAME%
>> README.md echo ```
>> README.md echo.
>> README.md echo ### Option B: Installing from Built Wheel
>> README.md echo ```cmd
>> README.md echo pip install path\to\%RAW_PROJECT_NAME%\dist\%MODULE_NAME%-0.1.0-py3-none-any.whl
>> README.md echo ```
>> README.md echo.
>> README.md echo ### Option C: Referencing in Consumer `pyproject.toml`
>> README.md echo ```toml
>> README.md echo [project]
>> README.md echo dependencies = [
>> README.md echo     "%RAW_PROJECT_NAME% @ file:///path/to/%RAW_PROJECT_NAME%"
>> README.md echo ]
>> README.md echo ```
>> README.md echo.
>> README.md echo ---
>> README.md echo.
>> README.md echo ## 4. Importing and Using in Python Code
>> README.md echo.
>> README.md echo ```python
>> README.md echo import %MODULE_NAME%
>> README.md echo.
>> README.md echo print(%MODULE_NAME%.__version__)
>> README.md echo ```

echo [CMD] Writing .gitignore...
> .gitignore echo venv/
>> .gitignore echo .venv/
>> .gitignore echo __pycache__/
>> .gitignore echo *.pyc
>> .gitignore echo *.egg-info/
>> .gitignore echo dist/
>> .gitignore echo build/
>> .gitignore echo .vscode/*
>> .gitignore echo !.vscode/settings.json

echo [CMD] Writing pyproject.toml...
> pyproject.toml echo [build-system]
>> pyproject.toml echo requires = ["hatchling"]
>> pyproject.toml echo build-backend = "hatchling.build"
>> pyproject.toml echo.
>> pyproject.toml echo [project]
>> pyproject.toml echo name = "%RAW_PROJECT_NAME%"
>> pyproject.toml echo version = "0.1.0"
>> pyproject.toml echo description = "A generic Python library."
>> pyproject.toml echo readme = "README.md"
>> pyproject.toml echo requires-python = ">=3.9"
>> pyproject.toml echo dependencies = []
>> pyproject.toml echo.
>> pyproject.toml echo [project.optional-dependencies]
>> pyproject.toml echo dev = [
>> pyproject.toml echo     "pytest",
>> pyproject.toml echo     "build",
>> pyproject.toml echo     "twine"
>> pyproject.toml echo ]

echo [CMD] Writing .vscode\settings.json...
> .vscode\settings.json echo {
>> .vscode\settings.json echo     "python.defaultInterpreterPath": "${workspaceFolder}/venv/Scripts/python.exe",
>> .vscode\settings.json echo     "python.terminal.activateEnvironment": true
>> .vscode\settings.json echo }

echo [CMD] Writing build_and_install.cmd...
> build_and_install.cmd echo @echo off
>> build_and_install.cmd echo echo =======================================================
>> build_and_install.cmd echo echo Building library package (.whl and .tar.gz)...
>> build_and_install.cmd echo echo =======================================================
>> build_and_install.cmd echo.
>> build_and_install.cmd echo call venv\Scripts\activate.bat
>> build_and_install.cmd echo python -m build
>> build_and_install.cmd echo.
>> build_and_install.cmd echo echo =======================================================
>> build_and_install.cmd echo echo Build complete! Wheel files generated in dist\ directory.
>> build_and_install.cmd echo echo To install locally in another project:
>> build_and_install.cmd echo echo   pip install -e %%CD%%
>> build_and_install.cmd echo echo =======================================================
>> build_and_install.cmd echo pause

echo [+] Configuration files written successfully.
echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: CREATE_VENV
:: Purpose:
::   Creates an isolated Python virtual environment ('venv') inside
::   the project folder using standard library tools.
:: Actions:
::   - Executes `python -m venv venv`
:: =========================================================
:CREATE_VENV
echo =======================================================
echo STEP 3/7: Creating Virtual Environment
echo =======================================================

echo [CMD] python -m venv venv
python -m venv venv
if errorlevel 1 (
    echo [ERROR] Failed to create virtual environment. Ensure Python is in PATH.
    exit /b 1
)

echo [+] Virtual environment directory created.
echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: UPGRADE_PIP_TOOLS [PIP SPECIFIC]
:: Purpose:
::   Activates the virtual environment and upgrades pip, build,
::   and setuptools using cached wheels when available.
:: Actions:
::   - Activates `venv\Scripts\activate.bat`
::   - Runs `python -m pip install --upgrade pip build setuptools --prefer-binary`
:: =========================================================
:UPGRADE_PIP_TOOLS
echo =======================================================
echo STEP 4/7: Upgrading Pip and Build Tools
echo =======================================================

if NOT EXIST "venv\Scripts\activate.bat" (
    echo [WARNING] Virtual environment not found. Skipping pip upgrades.
    exit /b 0
)

echo [CMD] call venv\Scripts\activate.bat
call venv\Scripts\activate.bat

echo [CMD] python -m pip install --upgrade pip build setuptools --prefer-binary
python -m pip install --upgrade pip build setuptools --prefer-binary
if errorlevel 1 (
    echo [ERROR] Failed to upgrade pip/build dependencies.
    exit /b 1
)

echo [+] Pip and build tools upgraded successfully.
echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: INSTALL_EDITABLE [PIP SPECIFIC]
:: Purpose:
::   Installs the local package into the virtual environment in
::   "editable mode" (-e) alongside development extras ([dev]).
:: Actions:
::   - Runs `pip install --prefer-binary -e .[dev]`
:: =========================================================
:INSTALL_EDITABLE
echo =======================================================
echo STEP 5/7: Installing Library in Editable Mode (Pip)
echo =======================================================

if NOT EXIST "venv\Scripts\activate.bat" (
    echo [WARNING] Virtual environment not found. Skipping editable install.
    exit /b 0
)

echo [CMD] pip install --prefer-binary -e .[dev]
pip install --prefer-binary -e .[dev]
if errorlevel 1 (
    echo [ERROR] Editable installation failed.
    exit /b 1
)

echo [+] Package installed locally in editable mode.
echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: INIT_GIT_REPO [GIT SPECIFIC]
:: Purpose:
::   Initializes a local Git repository, sets default branch to 'main',
::   stages all project files, and creates an initial commit cleanly.
:: Actions:
::   - Runs `git init`
::   - Runs `git branch -M main`
::   - Runs `git add .`
::   - Runs `git commit -m "Initial commit"`
:: =========================================================
:INIT_GIT_REPO
echo =======================================================
echo STEP 6/7: Initializing Git Repository
echo =======================================================

git --version >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Git is not installed or not in PATH. Skipping Git initialization.
    exit /b 0
)

echo [CMD] git init
git init >nul 2>&1
if errorlevel 1 exit /b 1

echo [CMD] git branch -M main
git branch -M main >nul 2>&1

echo [CMD] git add .
git add .
if errorlevel 1 exit /b 1

echo [CMD] git commit -m "Initial commit"
git commit -m "Initial commit" >nul 2>&1

if errorlevel 1 echo [WARNING] Git commit skipped (possibly missing user.name/user.email config).
if not errorlevel 1 echo [+] Git repository initialized on branch 'main' with initial commit.

echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: LAUNCH_VSCODE
:: Purpose:
::   Launches Visual Studio Code inside the root of the new project directory.
:: Actions:
::   - Runs `code .`
:: =========================================================
:LAUNCH_VSCODE
echo =======================================================
echo STEP 7/7: Launching VS Code Workspace
echo =======================================================

echo [CMD] code .
call code . >nul 2>&1
if errorlevel 1 echo [WARNING] 'code' command not found in PATH. Opening VS Code automatically skipped.
if not errorlevel 1 echo [+] VS Code launched successfully.

echo.
exit /b 0


:: =========================================================
:: SUBROUTINE: ON_ERROR
:: Purpose:
::   Global error handling routine triggered whenever any subroutine returns
::   a non-zero exit code (%errorlevel% neq 0). Halts execution gracefully.
:: =========================================================
:ON_ERROR
echo.
echo =======================================================
echo [FATAL ERROR] Command execution failed in current block.
echo Review the error log above to locate the exact issue.
echo =======================================================
pause
exit /b 1


:: =========================================================
:: MAIN EXECUTION PIPELINE
::
:: All execution commands are consolidated below.
:: To skip any block, comment out its 'call' line with '::'.
:: =========================================================
:MAIN_PIPELINE

call :PROMPT_USER_INPUT
if errorlevel 1 goto :ON_ERROR

call :CREATE_PROJECT_DIR
if errorlevel 1 goto :ON_ERROR

call :GENERATE_FILES
if errorlevel 1 goto :ON_ERROR

call :CREATE_VENV
if errorlevel 1 goto :ON_ERROR

:: --- Pip-Specific Commands ---
call :UPGRADE_PIP_TOOLS
if errorlevel 1 goto :ON_ERROR

call :INSTALL_EDITABLE
if errorlevel 1 goto :ON_ERROR

:: --- Git-Specific Commands ---
call :INIT_GIT_REPO
if errorlevel 1 goto :ON_ERROR

:: --- Workspace Launch ---
call :LAUNCH_VSCODE
if errorlevel 1 goto :ON_ERROR

echo.
echo =======================================================
echo SUCCESS: Setup pipeline completed for '%RAW_PROJECT_NAME%'!
echo =======================================================
pause
exit /b 0