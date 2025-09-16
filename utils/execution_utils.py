#!/usr/bin/env python3
"""
Execution utilities for the neuroimaging pipeline.
Supports both Slurm and local execution modes based on config.json settings.
"""

import json
import os
import subprocess
import sys
from pathlib import Path


def load_config(config_path="config.json"):
    """Load configuration from config.json file."""
    try:
        with open(config_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: {config_path} not found. Please create a config.json file.")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in {config_path}: {e}")
        sys.exit(1)


def generate_slurm_script(script_content, job_name, config):
    """Generate a Slurm script with appropriate headers."""
    slurm_config = config["execution_mode"]["slurm_settings"]
    
    slurm_header = f"""#!/bin/bash
#SBATCH --job-name={job_name}
#SBATCH --partition={slurm_config['partition']}
#SBATCH --time={slurm_config['time']}
#SBATCH --mem={slurm_config['mem']}
#SBATCH --cpus-per-task={slurm_config['cpus_per_task']}"""

    if slurm_config['account']:
        slurm_header += f"\n#SBATCH --account={slurm_config['account']}"
    
    if slurm_config['mail_type'] and slurm_config['mail_user']:
        slurm_header += f"\n#SBATCH --mail-type={slurm_config['mail_type']}"
        slurm_header += f"\n#SBATCH --mail-user={slurm_config['mail_user']}"

    slurm_header += f"""

# Load modules if needed
# module load matlab
# module load freesurfer

# Set environment variables
export CONFIG_PATH="{os.path.abspath('config.json')}"

{script_content}
"""
    return slurm_header


def run_local_command(command, config):
    """Run a command locally with optional parallel execution."""
    local_config = config["execution_mode"]["local_settings"]
    
    if local_config["use_gnu_parallel"]:
        # Use GNU parallel for local execution
        parallel_cmd = f"parallel -j {local_config['max_parallel_jobs']} ::: {command}"
        print(f"Running with GNU parallel: {parallel_cmd}")
        return subprocess.run(parallel_cmd, shell=True)
    else:
        # Run directly
        print(f"Running locally: {command}")
        return subprocess.run(command, shell=True)


def submit_slurm_job(script_path, config):
    """Submit a Slurm job."""
    slurm_config = config["execution_mode"]["slurm_settings"]
    cmd = f"sbatch {script_path}"
    print(f"Submitting Slurm job: {cmd}")
    return subprocess.run(cmd, shell=True)


def create_execution_script(script_name, commands, config_path="config.json"):
    """Create an execution script based on the configuration mode."""
    config = load_config(config_path)
    execution_mode = config["execution_mode"]["type"]
    
    if execution_mode == "slurm":
        # Create Slurm script
        slurm_script = generate_slurm_script(commands, script_name, config)
        script_path = f"{script_name}_slurm.sh"
        
        with open(script_path, 'w') as f:
            f.write(slurm_script)
        
        print(f"Created Slurm script: {script_path}")
        print("To submit the job, run:")
        print(f"sbatch {script_path}")
        
        return script_path
    
    elif execution_mode == "local":
        # Create local bash script
        local_script = f"""#!/bin/bash
# Local execution script for {script_name}
# Generated from config.json

set -e  # Exit on error

# Set environment variables
export CONFIG_PATH="{os.path.abspath(config_path)}"

{commands}
"""
        script_path = f"{script_name}_local.sh"
        
        with open(script_path, 'w') as f:
            f.write(local_script)
        
        # Make executable
        os.chmod(script_path, 0o755)
        
        print(f"Created local script: {script_path}")
        print("To run the script, execute:")
        print(f"./{script_path}")
        
        return script_path
    
    else:
        print(f"Error: Unknown execution mode '{execution_mode}'. Use 'slurm' or 'local'.")
        sys.exit(1)


def get_config_value(config, *keys, default=None):
    """Safely get a nested configuration value."""
    current = config
    for key in keys:
        if isinstance(current, dict) and key in current:
            current = current[key]
        else:
            return default
    return current


def validate_config(config):
    """Validate the configuration file."""
    required_sections = ["data_directories", "execution_mode"]
    
    for section in required_sections:
        if section not in config:
            print(f"Error: Missing required section '{section}' in config.json")
            return False
    
    execution_mode = config["execution_mode"]["type"]
    if execution_mode not in ["slurm", "local"]:
        print(f"Error: Invalid execution mode '{execution_mode}'. Use 'slurm' or 'local'.")
        return False
    
    return True


if __name__ == "__main__":
    # Example usage
    config = load_config()
    
    if validate_config(config):
        print("Configuration is valid!")
        print(f"Execution mode: {config['execution_mode']['type']}")
        print(f"Dataset root: {config['data_directories']['dataset_root']}")
    else:
        print("Configuration validation failed!")
        sys.exit(1) 