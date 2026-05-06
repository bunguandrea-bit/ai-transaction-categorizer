import re

def anonymize_description(text):
    if not text:
        return ""
    
    # Mascheramento IBAN (Pattern Italiano)
    text = re.sub(r'[A-Z]{2}\d{2}[A-Z]\d{22}', '[IBAN_HIDDEN]', text)
    
    # Mascheramento ID Transazione lunghi (es. 15+ cifre)
    text = re.sub(r'\d{15,}', '[ID_HIDDEN]', text)
    
    return text