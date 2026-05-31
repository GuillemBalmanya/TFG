with open('studentTheses.xslt', 'r') as f:
    content = f.read()
import re
content = re.sub(r'<xsl:value-of select="\$separator" />\s*<xsl:value-of select="\$newline" />', '<xsl:value-of select="$newline" />', content)
with open('studentTheses.xslt', 'w') as f:
    f.write(content)
