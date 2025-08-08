from flask import Flask, render_template, request, redirect, url_for, session

app = Flask(__name__)
app.secret_key = "supersecret"  # required for session

VALID_USERNAME = "admin"
VALID_PASSWORD = "password123"

@app.route('/')
def index():
    return render_template('login.html')

@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    
    if username == VALID_USERNAME and password == VALID_PASSWORD:
        session['username'] = username
        return redirect(url_for('welcome'))
    else:
        return render_template('error.html', message="Invalid credentials!")

@app.route('/welcome')
def welcome():
    if 'username' in session:
        return render_template('welcome.html', username=session['username'])
    return redirect(url_for('index'))

@app.route('/logout')
def logout():
    session.pop('username', None)
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
