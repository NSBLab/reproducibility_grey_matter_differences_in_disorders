# Execution Guide: Slurm vs Local Execution

This guide explains how to configure and run the neuroimaging pipeline using either Slurm (cluster) or local execution modes.

## Quick Start

1. **Configure your execution mode** in `config.json`:
   ```json
   "execution_mode": {
     "type": "local"  // or "slurm"
   }
   ```

2. **Run a pipeline stage**:
   ```bash
   python run_pipeline.py preprocessing
   python run_pipeline.py glm
   python run_pipeline.py combat
   ```

## Configuration Options

### Execution Mode Settings

#### Local Execution
```json
"execution_mode": {
  "type": "local",
  "local_settings": {
    "max_parallel_jobs": 4,
    "use_gnu_parallel": false
  }
}
```

#### Slurm Execution
```json
"execution_mode": {
  "type": "slurm",
  "slurm_settings": {
    "partition": "default",
    "time": "24:00:00",
    "mem": "8G",
    "cpus_per_task": 4,
    "account": "your_account",
    "mail_type": "END",
    "mail_user": "your_email@institution.edu"
  }
}
```

## Usage Examples

### 1. Dry Run (Preview Commands)
```bash
python run_pipeline.py preprocessing --dry-run
```
This shows what commands would be executed without actually running them.

### 2. Local Execution
```bash
# Set execution mode to local
# Edit config.json: "type": "local"

# Run preprocessing
python run_pipeline.py preprocessing
# Creates: pipeline_preprocessing_local.sh

# Execute the generated script
./pipeline_preprocessing_local.sh
```

### 3. Slurm Execution
```bash
# Set execution mode to slurm
# Edit config.json: "type": "slurm"

# Run preprocessing
python run_pipeline.py preprocessing
# Creates: pipeline_preprocessing_slurm.sh

# Submit to Slurm
sbatch pipeline_preprocessing_slurm.sh
```

## Pipeline Stages

The pipeline supports the following stages:

1. **preprocessing**: CAT12 preprocessing, QC reports, subject extraction
2. **glm**: Metadata combination, smoothing, masking, GLM analysis
3. **combat**: COMBAT harmonization and GLM
4. **nulltest**: Null hypothesis testing with BrainSmash
5. **analysis**: Correlation analysis and figure generation
6. **roi**: ROI-based analysis with parcellations

## Advanced Configuration

### Custom Slurm Settings

Modify the `slurm_settings` in `config.json`:

```json
"slurm_settings": {
  "partition": "gpu",           // Use GPU partition
  "time": "48:00:00",          // 48 hours
  "mem": "32G",                // 32GB memory
  "cpus_per_task": 8,          // 8 CPUs
  "account": "neuroimaging",   // Account name
  "mail_type": "ALL",          // Email on all events
  "mail_user": "user@uni.edu"  // Email address
}
```

### Local Parallel Execution

Enable GNU parallel for local execution:

```json
"local_settings": {
  "max_parallel_jobs": 8,
  "use_gnu_parallel": true
}
```

## Environment Variables

The system automatically sets:
- `CONFIG_PATH`: Path to your config.json file
- Working directory: Project root

## Troubleshooting

### Common Issues

1. **JSON Syntax Error**: Ensure all backslashes in Windows paths are escaped (`\\`)
2. **Permission Denied**: Make sure generated scripts are executable (`chmod +x script.sh`)
3. **Slurm Not Found**: Ensure you're on a system with Slurm installed
4. **MATLAB Not Found**: Add MATLAB to your PATH or load appropriate modules

### Validation

Test your configuration:
```bash
python utils/execution_utils.py
```

This will validate your `config.json` and show current settings.

## Manual Script Generation

You can also generate scripts manually:

```python
from utils.execution_utils import create_execution_script

# Create a custom script
commands = """
cd preprocessing
./my_custom_script.sh
"""

script_path = create_execution_script("my_analysis", commands)
```

## Best Practices

1. **Always use dry-run first** to preview commands
2. **Test with small datasets** before running full analysis
3. **Monitor resource usage** on local machines
4. **Use appropriate Slurm settings** for your cluster
5. **Keep config.json in version control** but exclude sensitive paths

## Integration with Existing Scripts

The system is designed to work with your existing shell scripts. It simply:
1. Wraps them with appropriate headers (Slurm or local)
2. Sets environment variables
3. Handles execution mode switching

Your existing scripts in `preprocessing/`, `combat/`, `analysis/`, etc. remain unchanged. 