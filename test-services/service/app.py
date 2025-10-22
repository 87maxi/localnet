from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def index():
    return "Welcome to the Test Services for MyERC20 Contract"

@app.route('/deploy', methods=['GET'])
def deploy():
    import subprocess
    result = subprocess.run(['bash', 'deploy.sh'], capture_output=True, text=True)
    return jsonify({"output": result.stdout, "error": result.stderr})

@app.route('/test', methods=['GET'])
def test():
    import subprocess
    result = subprocess.run(['bash', 'test.sh'], capture_output=True, text=True)
    return jsonify({"output": result.stdout, "error": result.stderr})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)