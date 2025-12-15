# VS Code Java Configuration Fix

## Problem
VS Code Java extension is treating `src/main/java` as part of the package name instead of recognizing it as the source root.

Error: `The declared package "com.devops.userservice.model" does not match the expected package "main.java.com.devops.userservice.model"`

## Solution

### Option 1: Reload VS Code Java Projects (Recommended)

1. **Open Command Palette** (Ctrl+Shift+P or Cmd+Shift+P)
2. Type and select: **"Java: Clean Java Language Server Workspace"**
3. Click **"Reload and delete"** when prompted
4. Wait for VS Code to reload and re-index the project

### Option 2: Force Maven Project Import

1. **Open Command Palette** (Ctrl+Shift+P)
2. Type and select: **"Java: Force Java Compilation"**
3. Then select: **"Java: Reload Projects"**

### Option 3: Manual Configuration

Create a `.vscode/settings.json` file in the DevOps directory with:

```json
{
  "java.project.sourcePaths": [
    "user-service/src/main/java",
    "product-service/src/main/java"
  ],
  "java.configuration.updateBuildConfiguration": "automatic"
}
```

### Option 4: Open Each Service as Separate Workspace

Instead of opening the entire `DevOps` folder, open each service individually:

1. **File → Open Folder**
2. Navigate to `DevOps/user-service` and open it
3. Repeat for `product-service`

This way VS Code will correctly recognize each as a Maven project.

### Option 5: Use Maven Extension

1. Install the **"Maven for Java"** extension if not already installed
2. Right-click on `pom.xml` in each service
3. Select **"Update Project"** or **"Reimport"**

## Verification

After applying any solution:

1. Check that the errors are gone
2. Run Maven compile:
   ```bash
   cd user-service
   mvn clean compile
   ```

3. If successful, the package structure is correct

## Why This Happens

VS Code's Java extension needs to understand the project structure. For Maven projects:
- `src/main/java` is the **source root**
- Packages start from there (e.g., `com.devops.userservice.model`)

When VS Code doesn't recognize this, it treats the entire path as the package name.

## Files Updated

I've updated both `pom.xml` files to explicitly declare source directories:
- `user-service/pom.xml`
- `product-service/pom.xml`

This helps VS Code and Maven understand the correct structure.

## Still Not Working?

If the issue persists:

1. **Close VS Code completely**
2. **Delete these folders** (they'll be regenerated):
   - `user-service/.classpath`
   - `user-service/.project`
   - `user-service/.settings`
   - `product-service/.classpath`
   - `product-service/.project`
   - `product-service/.settings`

3. **Reopen VS Code**
4. **Let the Java extension re-index** (watch the status bar)

## Alternative: Use IntelliJ IDEA

If VS Code continues to have issues, IntelliJ IDEA Community Edition (free) has better Maven support and will automatically recognize the structure correctly.
