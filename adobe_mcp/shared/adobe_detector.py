"""Detect Adobe application installations on Windows."""
import os
import platform
import json
from pathlib import Path

# Only import winreg on Windows
if platform.system() == "Windows":
    import winreg

def find_adobe_apps_windows():
    """Find Adobe application installations on Windows."""
    adobe_apps = {
        "photoshop": None,
        "premiere": None,
        "illustrator": None,
        "indesign": None
    }
    
    # Common installation paths to check
    program_files = [
        os.environ.get('PROGRAMFILES', 'C:\\Program Files'),
        os.environ.get('PROGRAMFILES(X86)', 'C:\\Program Files (x86)'),
        os.environ.get('PROGRAMW6432', 'C:\\Program Files')
    ]
    
    # Search patterns for each app
    app_patterns = {
        "photoshop": ["Adobe Photoshop*", "Photoshop.exe"],
        "premiere": ["Adobe Premiere Pro*", "Adobe Premiere Pro.exe"],
        "illustrator": ["Adobe Illustrator*", "Illustrator.exe"],
        "indesign": ["Adobe InDesign*", "InDesign.exe"]
    }
    
    # Search in Program Files
    for base_path in program_files:
        if not base_path or not os.path.exists(base_path):
            continue
            
        adobe_dir = os.path.join(base_path, "Adobe")
        if os.path.exists(adobe_dir):
            for app_name, patterns in app_patterns.items():
                if adobe_apps[app_name]:  # Already found
                    continue
                    
                # Look for app directories
                for item in os.listdir(adobe_dir):
                    if any(pattern.replace("*", "") in item for pattern in patterns[:-1]):
                        app_path = os.path.join(adobe_dir, item)
                        
                        # Find the executable
                        exe_name = patterns[-1]
                        for root, dirs, files in os.walk(app_path):
                            if exe_name in files:
                                adobe_apps[app_name] = os.path.join(root, exe_name)
                                break
    
    # Try to find from PATH environment variable
    path_dirs = os.environ.get('PATH', '').split(os.pathsep)
    for path_dir in path_dirs:
        if not os.path.exists(path_dir):
            continue
            
        for app_name, patterns in app_patterns.items():
            if adobe_apps[app_name]:  # Already found
                continue
                
            exe_name = patterns[-1]
            exe_path = os.path.join(path_dir, exe_name)
            if os.path.exists(exe_path):
                adobe_apps[app_name] = exe_path
    
    # Try Windows Registry
    try:
        for app_name in adobe_apps:
            if adobe_apps[app_name]:  # Already found
                continue
                
            # Check common registry locations
            registry_paths = [
                (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Adobe"),
                (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\WOW6432Node\Adobe"),
                (winreg.HKEY_CURRENT_USER, r"SOFTWARE\Adobe")
            ]
            
            for hkey, base_path in registry_paths:
                try:
                    with winreg.OpenKey(hkey, base_path) as adobe_key:
                        # Enumerate subkeys
                        for i in range(winreg.QueryInfoKey(adobe_key)[0]):
                            subkey_name = winreg.EnumKey(adobe_key, i)
                            if app_name in subkey_name.lower():
                                # Try to find install path
                                try:
                                    with winreg.OpenKey(adobe_key, subkey_name) as app_key:
                                        install_path = winreg.QueryValueEx(app_key, "InstallPath")[0]
                                        exe_name = app_patterns[app_name][-1]
                                        exe_path = os.path.join(install_path, exe_name)
                                        if os.path.exists(exe_path):
                                            adobe_apps[app_name] = exe_path
                                except:
                                    pass
                except:
                    pass
    except:
        pass
    
    return adobe_apps

def get_adobe_config():
    """Get Adobe application paths and configuration."""
    if platform.system() != "Windows":
        raise OSError("This function is only supported on Windows")
    
    adobe_paths = find_adobe_apps_windows()
    
    # Create configuration
    config = {
        "platform": "windows",
        "adobePaths": {},
        "proxy": {
            "host": "localhost",
            "port": 3001,
            "timeout": 30000
        },
        "mcp": {
            "timeout": 30,
            "logLevel": "INFO"
        }
    }
    
    # Add found paths
    for app, path in adobe_paths.items():
        if path:
            config["adobePaths"][app] = path
            print(f"Found {app}: {path}")
        else:
            print(f"Warning: {app} not found")
    
    return config

def save_config(config, filepath="config.windows.json"):
    """Save configuration to file."""
    with open(filepath, 'w') as f:
        json.dump(config, f, indent=2)
    print(f"Configuration saved to {filepath}")

if __name__ == "__main__":
    try:
        config = get_adobe_config()
        save_config(config)
    except Exception as e:
        print(f"Error: {e}")