#!/usr/bin/env python3#!/usr/bin/env python3

"""Fix markdown linting errors in README.md""""""

Fix markdown linting errors in README.md

import re"""

import re

def fix_markdown(content):

    lines = content.split('\n')def fix_markdown(filepath):

    fixed_lines = []    """Fix common markdown linting errors"""

    i = 0    with open(filepath, 'r', encoding='utf-8') as f:

            content = f.read()

    while i < len(lines):    

        line = lines[i]    # Fix MD019: Multiple spaces after hash

            content = re.sub(r'^##  +', '## ', content, flags=re.MULTILINE)

        # Fix MD022: Add blank lines around headings    content = re.sub(r'^###  +', '### ', content, flags=re.MULTILINE)

        if line.startswith('#'):    content = re.sub(r'^####  +', '#### ', content, flags=re.MULTILINE)

            # Add blank line before heading if not at start and previous line isn't blank    

            if i > 0 and fixed_lines and fixed_lines[-1].strip():    # Fix MD037: Spaces inside emphasis markers

                fixed_lines.append('')    content = re.sub(r'\*\* +([^*]+?) +\*\*', r'**\1**', content)

                

            # Fix MD019: Remove multiple spaces after hash    # Fix MD026: Remove trailing colons from headings

            line = re.sub(r'^(#{1,6})\s{2,}', r'\1 ', line)    content = re.sub(r'^(#{1,6} .+?):$', r'\1', content, flags=re.MULTILINE)

                

            # Fix MD026: Remove trailing punctuation in headings    # Fix MD009: Remove trailing spaces

            line = re.sub(r'^(#{1,6}\s+.*?)[:.!?]+\s*$', r'\1', line)    lines = content.split('\n')

                fixed_lines = []

            fixed_lines.append(line)    for line in lines:

                    # Keep lines with 2 trailing spaces (markdown line breaks)

            # Add blank line after heading if next line isn't blank        if line.endswith('  '):

            if i + 1 < len(lines) and lines[i + 1].strip():            fixed_lines.append(line)

                fixed_lines.append('')        else:

                    fixed_lines.append(line.rstrip())

        # Fix MD009: Remove trailing spaces    content = '\n'.join(fixed_lines)

        elif line.endswith(' ') and not line.endswith('  '):    

            fixed_lines.append(line.rstrip())    # Fix MD031: Add blank lines around code fences

            lines = content.split('\n')

        # Fix MD037: Fix spaces inside emphasis markers    fixed_lines = []

        elif '**' in line or '__' in line:    for i, line in enumerate(lines):

            # Fix ** with spaces inside        # Check if this is a code fence

            line = re.sub(r'\*\*\s+([^*]+?)\s+\*\*', r'**\1**', line)        if line.strip().startswith('```'):

            line = re.sub(r'__\s+([^_]+?)\s+__', r'__\1__', line)            # Add blank line before if not present

            fixed_lines.append(line)            if i > 0 and fixed_lines and fixed_lines[-1].strip() != '':

                        fixed_lines.append('')

        # Fix MD030: Fix list marker spacing            fixed_lines.append(line)

        elif re.match(r'^(\s*[-*+])\s{2,}', line):            # Add blank line after closing fence

            line = re.sub(r'^(\s*[-*+])\s{2,}', r'\1 ', line)            if line.strip() == '```' and i < len(lines) - 1:

            fixed_lines.append(line)                fixed_lines.append(line)

                        if i + 1 < len(lines) and lines[i + 1].strip() != '':

        # Fix MD032 & MD031: Add blank lines around lists and code fences                    fixed_lines.append('')

        elif line.strip().startswith(('- ', '* ', '+ ')) or re.match(r'^\d+\.\s', line.strip()):                continue

            # Add blank before list if previous isn't blank/list/heading        else:

            if (i > 0 and fixed_lines and fixed_lines[-1].strip() and             fixed_lines.append(line)

                not fixed_lines[-1].strip().startswith(('#', '-', '*', '+')) and    content = '\n'.join(fixed_lines)

                not re.match(r'^\d+\.', fixed_lines[-1].strip())):    

                fixed_lines.append('')    # Remove duplicate empty lines (but keep paragraph breaks)

            fixed_lines.append(line)    content = re.sub(r'\n{4,}', '\n\n\n', content)

            

        elif line.strip().startswith('```'):    # Fix MD040: Add language to fenced code blocks without language

            # Add blank before code fence if needed    content = re.sub(r'\n```\n', '\n```text\n', content)

            if i > 0 and fixed_lines and fixed_lines[-1].strip():    

                fixed_lines.append('')    with open(filepath, 'w', encoding='utf-8') as f:

                    f.write(content)

            # Add language if missing    

            if line.strip() == '```':    print(f"Fixed markdown errors in {filepath}")

                # Look ahead to guess language

                if i + 1 < len(lines):if __name__ == '__main__':

                    next_line = lines[i + 1].strip()    fix_markdown('/workspaces/SPLANTS/README.md')

                    if any(x in next_line for x in ['import', 'def ', 'class ', 'print(']):
                        line = '```python'
                    elif any(x in next_line for x in ['const ', 'let ', 'var ', 'function']):
                        line = '```javascript'
                    elif any(x in next_line for x in ['docker', 'FROM', 'RUN']):
                        line = '```dockerfile'
                    elif next_line.startswith('$') or next_line.startswith('#'):
                        line = '```bash'
            
            fixed_lines.append(line)
            
            # Find closing fence
            i += 1
            while i < len(lines) and not lines[i].strip().startswith('```'):
                fixed_lines.append(lines[i])
                i += 1
            
            if i < len(lines):
                fixed_lines.append(lines[i])
                # Add blank after code fence if needed
                if i + 1 < len(lines) and lines[i + 1].strip():
                    fixed_lines.append('')
        
        # Fix MD034: Wrap bare URLs
        elif 'http://' in line or 'https://' in line:
            # Find bare URLs not already in markdown links or code
            line = re.sub(r'(?<![(\[])(https?://[^\s<>)\]]+)(?![)\]])', r'<\1>', line)
            fixed_lines.append(line)
        
        # Fix MD029: Fix ordered list prefixes
        elif re.match(r'^\s*\d+\.\s', line):
            # This needs context of surrounding list items
            fixed_lines.append(line)
        
        else:
            fixed_lines.append(line)
        
        i += 1
    
    # Second pass: fix list spacing
    result = []
    i = 0
    while i < len(fixed_lines):
        line = fixed_lines[i]
        result.append(line)
        
        # Add blank after list if next line isn't blank/list/heading/fence
        if (line.strip().startswith(('- ', '* ', '+ ')) or re.match(r'^\d+\.\s', line.strip())):
            if (i + 1 < len(fixed_lines) and 
                fixed_lines[i + 1].strip() and
                not fixed_lines[i + 1].strip().startswith(('#', '-', '*', '+', '```', '|')) and
                not re.match(r'^\d+\.', fixed_lines[i + 1].strip()) and
                not fixed_lines[i + 1].strip().startswith('   ')):  # Not a continuation
                result.append('')
        
        i += 1
    
    return '\n'.join(result)

# Read the file
with open('/workspaces/SPLANTS/README.md', 'r') as f:
    content = f.read()

# Fix markdown
fixed_content = fix_markdown(content)

# Write back
with open('/workspaces/SPLANTS/README.md', 'w') as f:
    f.write(fixed_content)

print("✓ Fixed markdown linting errors")
