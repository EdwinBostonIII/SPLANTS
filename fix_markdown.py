#!/usr/bin/env python3
"""
Fix markdown linting errors in README.md
"""
import re

def fix_markdown(filepath):
    """Fix common markdown linting errors"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix MD019: Multiple spaces after hash
    content = re.sub(r'^##  +', '## ', content, flags=re.MULTILINE)
    content = re.sub(r'^###  +', '### ', content, flags=re.MULTILINE)
    content = re.sub(r'^####  +', '#### ', content, flags=re.MULTILINE)
    
    # Fix MD037: Spaces inside emphasis markers
    content = re.sub(r'\*\* +([^*]+?) +\*\*', r'**\1**', content)
    
    # Fix MD026: Remove trailing colons from headings
    content = re.sub(r'^(#{1,6} .+?):$', r'\1', content, flags=re.MULTILINE)
    
    # Fix MD009: Remove trailing spaces
    lines = content.split('\n')
    fixed_lines = []
    for line in lines:
        # Keep lines with 2 trailing spaces (markdown line breaks)
        if line.endswith('  '):
            fixed_lines.append(line)
        else:
            fixed_lines.append(line.rstrip())
    content = '\n'.join(fixed_lines)
    
    # Fix MD031: Add blank lines around code fences
    lines = content.split('\n')
    fixed_lines = []
    for i, line in enumerate(lines):
        # Check if this is a code fence
        if line.strip().startswith('```'):
            # Add blank line before if not present
            if i > 0 and fixed_lines and fixed_lines[-1].strip() != '':
                fixed_lines.append('')
            fixed_lines.append(line)
            # Add blank line after closing fence
            if line.strip() == '```' and i < len(lines) - 1:
                fixed_lines.append(line)
                if i + 1 < len(lines) and lines[i + 1].strip() != '':
                    fixed_lines.append('')
                continue
        else:
            fixed_lines.append(line)
    content = '\n'.join(fixed_lines)
    
    # Remove duplicate empty lines (but keep paragraph breaks)
    content = re.sub(r'\n{4,}', '\n\n\n', content)
    
    # Fix MD040: Add language to fenced code blocks without language
    content = re.sub(r'\n```\n', '\n```text\n', content)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed markdown errors in {filepath}")

if __name__ == '__main__':
    fix_markdown('/workspaces/SPLANTS/README.md')
