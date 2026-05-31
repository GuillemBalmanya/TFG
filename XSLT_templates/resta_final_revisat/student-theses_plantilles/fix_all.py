import os, glob, re
for f_name in glob.glob('*.xslt'):
    with open(f_name, 'r') as f:
        content = f.read()
    content = re.sub(r'<xsl:value-of select="\$separator" />\s*<xsl:value-of select="\$newline" />', '<xsl:value-of select="$newline" />', content)
    with open(f_name, 'w') as f:
        f.write(content)
