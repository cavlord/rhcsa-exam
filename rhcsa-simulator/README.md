# RHCSA Exam Simulator - Killercoda Scenario

## Upload to Killercoda

1. Go to https://killercoda.com
2. Sign in and click "Create Scenario"
3. Upload all files maintaining the directory structure

## Directory Structure

```
rhcsa-simulator/
â”œâ”€â”€ index.json          # Main configuration
â”œâ”€â”€ intro.md            # Introduction page
â”œâ”€â”€ finish.md           # Completion page
â”œâ”€â”€ step1/
â”‚   â”œâ”€â”€ text.md        # Step 1 instructions
â”‚   â””â”€â”€ setup.sh       # Auto-run setup script
â”œâ”€â”€ step2/
â”‚   â””â”€â”€ text.md        # Step 2 instructions (exam tasks)
â””â”€â”€ assets/
    â”œâ”€â”€ setup_lab.sh    # Lab setup script (from bundle)
    â”œâ”€â”€ validate_lab.sh # Validation script (from bundle)
    â”œâ”€â”€ reset_lab.sh    # Reset script (from bundle)
    â””â”€â”€ questions.txt   # Exam questions (from bundle) â­
```

## Questions Location

The exam questions from your bundle are placed in:
- **assets/questions.txt** - Copied to /root/questions.txt in the terminal
- Students view them with: `cat /root/questions.txt`

## How It Works

1. **intro.md** - Welcome page
2. **step1/** - Auto-runs setup_lab.sh
3. **step2/** - Shows exam tasks
4. **assets/** - Your scripts from bundle
5. **finish.md** - Completion page

## Notes

- All scripts run with root privileges in Killercoda
- RHEL 9 environment
- Full terminal access
