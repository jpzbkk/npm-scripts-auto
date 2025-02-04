# NPM Scripts Auto-Loader for Zsh

This script automatically loads all `npm` scripts from the `package.json` in your current directory, allowing you to run them directly as commands without using `npm run`.

## 🚀 Features

- **Automatic Detection**: When you `cd` into a directory with a `package.json`, all scripts are instantly available as commands.
- **Dynamic Updates**: Switching directories refreshes the commands, ensuring only relevant scripts are available.
- **Simple Setup**: Just source the script in your `~/.zshrc` and you're ready to go.

---

## 📦 Installation

1. **Download the Script**

\`\`\`bash
curl -o ~/npm-scripts-auto.sh https://path-to-your-script.sh
\`\`\`
*(Replace the URL with the actual script location if hosting it somewhere)*

Or create the file manually:

\`\`\`bash
touch ~/npm-scripts-auto.sh
nano ~/npm-scripts-auto.sh
\`\`\`

Then paste the [script content](#) into it.

2. **Make It Executable (Optional)**

\`\`\`bash
chmod +x ~/npm-scripts-auto.sh
\`\`\`

3. **Source the Script in Zsh**

Edit your `~/.zshrc`:

\`\`\`bash
nano ~/.zshrc
\`\`\`

Add this line:

\`\`\`bash
source ~/npm-scripts-auto.sh
\`\`\`

Reload your shell:

\`\`\`bash
source ~/.zshrc
\`\`\`

---

## ⚡ Usage

Just `cd` into any project folder with a `package.json`:

\`\`\`bash
cd ~/projects/my-app
\`\`\`

Assuming your `package.json` looks like this:

\`\`\`json
{
  "scripts": {
    "start": "node app.js",
    "build": "webpack",
    "test": "jest"
  }
}
\`\`\`

You can now run:

\`\`\`bash
start   # Runs 'npm run start'
build   # Runs 'npm run build'
test    # Runs 'npm run test'
\`\`\`

No need for `npm run`!

---

## 🛠️ How It Works

- Uses the Zsh `chpwd` hook to detect when you change directories.
- Parses the `package.json` with `jq` to extract all script names.
- Dynamically creates functions named after the scripts, which internally run `npm run <script>`.

---

## ⚠️ Requirements

- **Zsh** (this won't work with Bash or other shells).
- **jq** for parsing JSON:

\`\`\`bash
# macOS
brew install jq

# Debian/Ubuntu
sudo apt-get install jq
\`\`\`

---

## 🧹 Removing or Disabling

If you want to disable this feature:

1. Remove or comment out the line in your `~/.zshrc`:

\`\`\`bash
# source ~/npm-scripts-auto.sh
\`\`\`

2. Reload the config:

\`\`\`bash
source ~/.zshrc
\`\`\`

---

## 📝 License

MIT License. Feel free to modify and adapt as needed.
