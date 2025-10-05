from flask import Flask, request
from flask_cors import CORS
import PyPDF2
import docx

app = Flask(__name__)
CORS(app)

@app.route('/extract', methods=['POST'])
def extract():
    f = request.files['file']
    ext = f.filename.split('.')[-1].lower()
    text = ""
    if ext == 'pdf':
        reader = PyPDF2.PdfReader(f)
        text = "\n".join(page.extract_text() or '' for page in reader.pages)
    elif ext == 'docx':
        doc = docx.Document(f)
        text = "\n".join([p.text for p in doc.paragraphs])
    else:
        text = "Unsupported file type."
    return text

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)

