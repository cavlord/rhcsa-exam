# Complete RHCSA Tasks

## View Your Tasks

```bash
cat /root/questions.txt
```

## Important Notes

1. **Time Management**: In a real exam, you have 2 hours
2. **Root Access**: You have full root privileges
3. **Persistence**: Changes persist across reboots
4. **Documentation**: You can use `man` pages and `--help`

## Validate Your Work

After completing tasks, check your solutions:

```bash
./validate_lab_complete.sh
```

## Reset Environment

If you want to start over:

```bash
./reset_lab.sh
./setup_lab_ubuntu.sh
```

## Interactive Menu

Use the interactive menu for easier navigation:

```bash
./rhcsa_exam_menu.sh
```

## Tips

- Read each question carefully
- Test your configurations
- Use `systemctl status` to check services
- Verify file permissions with `ls -l`
- Check logs in `/var/log/` if something fails

Good luck! ðŸš€
