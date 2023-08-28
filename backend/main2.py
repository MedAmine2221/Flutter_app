import datetime
from flask import Flask, request, jsonify, session
from flaskext.mysql import MySQL
from werkzeug.security import generate_password_hash, check_password_hash
from flask_restful import Api, Resource
from flasgger import Swagger, swag_from
from flask_cors import CORS
import datetime


app = Flask(__name__)
CORS(app) 
swagger = Swagger(app)
app.secret_key = 'your_secret_key'

# Configuration de MySQL
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = ''
app.config['MYSQL_DATABASE_DB'] = 'stage'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'

mysql = MySQL(app)
api = Api(app)


def get_cursor_and_connection():
    conn = mysql.connect()
    cursor = conn.cursor()
    return conn, cursor

def close_connection(conn, cursor):
    cursor.close()
    conn.close()

def check_existing_employee(cin, email):
    conn, cursor = get_cursor_and_connection()
    cursor.execute("SELECT * FROM employee WHERE cin = %s OR email = %s", (cin, email))
    existing_employee = cursor.fetchone()
    close_connection(conn, cursor)
    return existing_employee

def insert_employee(cin, email, nom, prenom, mot_de_passe, role, image):
    conn, cursor = get_cursor_and_connection()
    cursor.execute("INSERT INTO employee (cin, email, lastname, firstname, password, role, image) VALUES (%s, %s, %s, %s, %s, %s, %s)",
                   (cin, email, nom, prenom, mot_de_passe, role, image))
    conn.commit()
    close_connection(conn, cursor)

def get_all_employees():
    conn, cursor = get_cursor_and_connection()
    cursor.execute("SELECT  email,password FROM employee")
    employees = cursor.fetchall()
    close_connection(conn, cursor)
    return employees

@app.route('/ajouter_employee', methods=['POST'])
@swag_from({
    'tags': ['Employees'],
    'summary': 'Ajouter un nouvel employé',
    'parameters': [
        {
            'name': 'cin',
            'description': 'Numéro CIN de l\'employé',
            'in': 'formData',
            'required': True,
            'type': 'string'
        },
        {
            'name': 'email',
            'description': 'email de l\'employé',
            'in': 'formData',
            'required': True,
            'type': 'string'
        },
        {
            'name': 'nom',
            'description': 'Nom de famille de l\'employé',
            'in': 'formData',
            'required': True,
            'type': 'string'
        },
        {
            'name': 'prenom',
            'description': 'prénom de l\'employé',
            'in': 'formData',
            'required': True,
            'type': 'string'
        },
        {
            'name': 'mot_de_passe',
            'description': 'mot de passe ',
            'in': 'formData',
            'required': True,
            'type': 'string'
        },
        {
            'name': 'role',
            'description': 'mode d\'accées ',
            'in': 'formData',
            'required': True,
            'type': 'string'
        },
        
    ],
    'responses': {
        201: {
            'description': 'Employé enregistré avec succès',
            'schema': {
                'type': 'object',
                'properties': {
                    'message': {
                        'type': 'string'
                    }
                }
            }
        },
        400: {
            'description': 'Numéro de cin ou email déjà existant'
        }
    }
})
def ajouter_employee():
    data = request.json
    cin = data.get('cin')
    email = data.get('email')
    nom = data.get('nom')
    prenom = data.get('prenom')
    role = data.get('role')
    image = data.get('image')

    mot_de_passe = generate_password_hash(data.get('mot_de_passe'))

    existing_employee = check_existing_employee(cin, email)
    if existing_employee:
        return jsonify({"message": "Numéro de cin ou email déjà existant. Veuillez utiliser des valeurs uniques."}), 400

    insert_employee(cin, email, nom, prenom, mot_de_passe, role, image)
        
    return jsonify({"message": "Employé enregistré avec succès!"}), 201



@app.route('/afficher_employee/<int:employee_id>', methods=['GET'])
@swag_from({
    'tags': ['Employees'],
    'summary': 'Afficher les détails d\'un employé',
    'parameters': [
        {
            'name': 'employee_id',
            'description': 'ID de l\'employé',
            'in': 'path',
            'required': True,
            'type': 'integer'
        }
    ],
    'responses': {
        200: {
            'description': 'Détails de l\'employé',
            'schema': {
                'type': 'object',
                'properties': {
                    'cin': {'type': 'string'},
                    'email': {'type': 'string'},
                    'nom': {'type': 'string'},
                    'prenom': {'type': 'string'},
                    'role': {'type': 'string'},
                    'image': {'type': 'string'}
                    # Ajoutez d'autres propriétés ici si nécessaire
                }
            }
        },
        404: {
            'description': 'Aucun employé trouvé avec cet ID'
        }
    }
})
def afficher_employee(employee_id):
    conn, cursor = get_cursor_and_connection()
    cursor.execute("SELECT cin, email, lastname, firstname, role, image FROM employee WHERE id = %s", (employee_id,))
    employee = cursor.fetchone()
    close_connection(conn, cursor)
    
    if employee:
        employee_data = {
            'cin': employee[0],
            'email': employee[1],
            'nom': employee[2],
            'prenom': employee[3],
            'role': employee[4],
            'image': employee[5]
        }
        return jsonify(employee_data), 200
    else:
        return jsonify({"message": "Aucun employé trouvé avec cet ID"}), 404



@app.route('/login', methods=['POST'])
@swag_from({
    'tags': ['Authentication'],
    'summary': 'Authentification de l\'utilisateur',
    'parameters': [
        {
            'name': 'email',
            'description': 'Email de l\'utilisateur',
            'in': 'formData',
            'required': True,
            'type': 'string'
        },
        {
            'name': 'mot_de_passe',
            'description': 'Mot de passe de l\'utilisateur',
            'in': 'formData',
            'required': True,
            'type': 'string'
        }
    ],
    'responses': {
        200: {
            'description': 'Connexion réussie',
            'schema': {
                'type': 'object',
                'properties': {
                    'cin': {'type': 'string'},
                    'email': {'type': 'string'},
                    'nom': {'type': 'string'},
                    'prenom': {'type': 'string'},
                    'role': {'type': 'string'}
                }
            }
        },
        405: {
            'description': 'Identifiants invalides'
        }
    }
})
def login():
    data = request.json
    email = data.get('email')
    password = data.get('mot_de_passe')

    conn, cursor = get_cursor_and_connection()
    cursor.execute("SELECT cin, email, password, lastname, firstname, role, image, id FROM employee WHERE email = %s", (email,))
    user = cursor.fetchone()
    close_connection(conn, cursor)

    if user and check_password_hash(user[2], password):
        session['user'] = {
            'cin': user[0],
            'email': user[1],
            'nom': user[4],
            'prenom': user[3],
            'role': user[5],
            'image': user[6],
            'id': user[7]
        }
        return jsonify(session['user']), 200
    else:
        return jsonify("Identifiants invalides"), 405

@app.route('/afficher_employees', methods=['GET'])
@swag_from({
    'tags': ['Employees'],
    'summary': 'Afficher la liste des employés',
    'responses': {
        200: {
            'description': 'Liste des employés récupérée avec succès',
            'schema': {
                'type': 'array',
                'items': {
                    'type': 'object',
                    'properties': {
                        'cin': {'type': 'string'},
                        'email': {'type': 'string'},
                        'nom': {'type': 'string'},
                        'prenom': {'type': 'string'},
                        'role': {'type': 'string'}
                    }
                }
            }
        }
    }
})
def afficher_employees():
    conn, cursor = get_cursor_and_connection()
    cursor.execute("SELECT cin, email, lastname, firstname, role, image FROM employee")
    employees = cursor.fetchall()
    close_connection(conn, cursor)

    employee_list = []
    for emp in employees:
        emp_dict = {
            'cin': emp[0],
            'email': emp[1],
            'nom': emp[3],
            'prenom': emp[2],
            'role': emp[4],
            'image': emp[5]

        }
        employee_list.append(emp_dict)

    return jsonify(employee_list)

@app.route('/rechercher_employee', methods=['POST'])
@swag_from({
    'tags': ['Employees'],
    'summary': 'Rechercher des employés',
    'parameters': [
        {
            'name': 'search_term',
            'description': 'Terme de recherche',
            'in': 'formData',
            'required': True,
            'type': 'string'
        }
    ],
    'responses': {
        200: {
            'description': 'Employés récupérés avec succès',
            'schema': {
                'type': 'array',
                'items': {
                    'type': 'object',
                    'properties': {
                        'cin': {'type': 'string'},
                        'email': {'type': 'string'},
                        'nom': {'type': 'string'},
                        'prenom': {'type': 'string'},
                        'role': {'type': 'string'}
                    }
                }
            }
        },
        404: {
            'description': 'Aucun résultat trouvé.'
        }
    }
})
def rechercher_employee():
    data = request.json
    search_term = data.get('search_term')

    conn, cursor = get_cursor_and_connection()
    cursor.execute("SELECT cin, email, lastname, firstname, role FROM employee WHERE cin = %s OR email = %s OR lastname = %s OR firstname = %s OR role = %s",
                   (search_term, search_term, search_term, search_term, search_term))
    search_results = cursor.fetchall()
    close_connection(conn, cursor)

    if not search_results:
        return jsonify({"message": "Aucun résultat trouvé."}), 404

    result_list = []
    for result in search_results:
        result_dict = {
            'cin': result[0],
            'email': result[1],
            'nom': result[3],
            'prenom': result[2],
            'role': result[4]
        }
        result_list.append(result_dict)

    return jsonify(result_list)


@app.route('/supprimer_employee/<string:cin>', methods=['GET'])
@swag_from({
    'tags': ['Employees'],
    'summary': 'Supprimé employé',
    'parameters': [
        {
            'name': 'cin',
            'description': 'Numéro CIN de l\'employé a supprimé',
            'in': 'path',
            'required': True,
            'type': 'string'
        }
    ],
    'responses': {
        200: {
            'description': 'employé supprimé avec succès',
        },
        404: {
            'description': 'Employé non trouvé'
        }
    }
})
def supprimer_employee(cin):
    try:
        connection = mysql.connect()
        cursor = connection.cursor()
        cursor.execute("DELETE FROM employee WHERE cin=%s", (cin,))
        connection.commit()
        return jsonify(message="Employee deleted successfully"), 200
    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        connection.close()

@app.route('/supprimer_employees', methods=['POST'])
@swag_from({
    'tags': ['Employees'],
    'summary': 'Supprimer plusieurs employés',
    'parameters': [
        {
            'name': 'body',
            'in': 'body',
            'description': 'Liste des numéros CIN des employés à supprimer',
            'required': True,
            'schema': {
                'type': 'object',
                'properties': {
                    'cins': {
                        'type': 'array',
                        'items': {
                            'type': 'string'
                        }
                    }
                }
            }
        }
    ],
    'responses': {
        200: {
            'description': 'Employés supprimés avec succès',
            'schema': {
                'type': 'object',
                'properties': {
                    'message': {
                        'type': 'string'
                    }
                }
            }
        },
        500: {
            'description': 'Erreur lors de la suppression des employés'
        }
    }
})
#def supprimer_employees():
#    try:
#        data = request.get_json()
#        cins = data.get('cins', [])  # Liste des numéros CIN à supprimer

#        connection = mysql.connect()
#        cursor = connection.cursor()

        # Utilisation d'une seule requête SQL pour supprimer les employés en utilisant IN
#        cursor.execute("DELETE FROM employee WHERE cin IN %s", (cins,))
#        connection.commit()

#        return jsonify(message="Employees deleted successfully"), 200
#    except Exception as e:
#        return jsonify(error=str(e)), 500
#    finally:
#        connection.close()
def supprimer_employees():
    try:
        data = request.get_json()
        cins = data.get('cins', [])  # Liste des numéros CIN à supprimer

        connection = mysql.connect()
        cursor = connection.cursor()

        cins_str = ', '.join(['%s'] * len(cins))  # Create a string of '%s' placeholders
        query = f"DELETE FROM employee WHERE cin IN ({cins_str})"
        cursor.execute(query, cins)  # Pass the list of CIN numbers directly
        
        connection.commit()

        return jsonify(message="Employés supprimés avec succès"), 200
    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        connection.close()

@app.route('/editer_employee/<string:cin>', methods=['PUT'])
@swag_from({
    'tags': ['Employees'],
    'summary': 'Modifier les informations d\'un employé',
    'parameters': [
        {
            'name': 'cin',
            'description': 'Numéro CIN de l\'employé à éditer',
            'in': 'path',
            'required': True,
            'type': 'string'
        },
        {
            'name': 'new_email',
            'description': 'Nouvelle adresse email de l\'employé',
            'in': 'formData',
            'required': False,
            'type': 'string'
        },
        {
            'name': 'new_nom',
            'description': 'Nouveau nom de l\'employé',
            'in': 'formData',
            'required': False,
            'type': 'string'
        },
        {
            'name': 'new_prenom',
            'description': 'Nouveau prénom de l\'employé',
            'in': 'formData',
            'required': False,
            'type': 'string'
        },
        {
            'name': 'new_role',
            'description': 'Nouveau rôle de l\'employé',
            'in': 'formData',
            'required': False,
            'type': 'string'
        }
    ],
    'responses': {
        200: {
            'description': 'Informations de l\'employé modifiées avec succès',
            'schema': {
                'type': 'object',
                'properties': {
                    'message': {
                        'type': 'string'
                    }
                }
            }
        },
        404: {
            'description': 'Employé non trouvé'
        }
    }
})
def editer_employee(cin):
    try:
        data = request.json
        new_email = data.get('new_email')
        new_nom = data.get('new_nom')
        new_prenom = data.get('new_prenom')
        new_role = data.get('new_role')
        new_image = data.get('new_image')
        
        conn, cursor = get_cursor_and_connection()
        cursor.execute("SELECT * FROM employee WHERE cin = %s", (cin,))
        existing_employee = cursor.fetchone()

        if existing_employee:
            update_query = "UPDATE employee SET "
            update_data = []

            if new_email:
                update_query += "email = %s, "
                update_data.append(new_email)
            if new_nom:
                update_query += "lastname = %s, "
                update_data.append(new_nom)
            if new_prenom:
                update_query += "firstname = %s, "
                update_data.append(new_prenom)
            if new_role:
                update_query += "role = %s, "
                update_data.append(new_role)
            if new_image:
                update_query += "image = %s, "
                update_data.append(new_image)

            if update_data:
                update_query = update_query[:-2]  # Remove the trailing comma and space
                update_query += " WHERE cin = %s"
                update_data.append(cin)

                cursor.execute(update_query, tuple(update_data))
                conn.commit()

                return jsonify(message="Employee updated successfully"), 200
            else:
                return jsonify(message="No changes to update"), 200
        else:
            return jsonify(message="Employee not found"), 404

    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        close_connection(conn, cursor)

@app.route('/changer_mot_de_passe', methods=['POST'])
@swag_from({
    'tags': ['Authentication'],
    'summary': 'Changer le mot de passe de l\'utilisateur',
    'parameters': [
        {
            'name': 'cin',
            'description': 'Numéro CIN de l\'utilisateur',
            'in': 'formData',
            'required': True,
            'type': 'string'
        },
        {
            'name': 'mot_de_passe_actuel',
            'description': 'Mot de passe actuel de l\'utilisateur',
            'in': 'formData',
            'required': True,
            'type': 'string'
        },
        {
            'name': 'nouveau_mot_de_passe',
            'description': 'Nouveau mot de passe de l\'utilisateur',
            'in': 'formData',
            'required': True,
            'type': 'string'
        }
    ],
    'responses': {
        200: {
            'description': 'Mot de passe changé avec succès',
            'schema': {
                'type': 'object',
                'properties': {
                    'message': {
                        'type': 'string'
                    }
                }
            }
        },
        401: {
            'description': 'Mot de passe actuel incorrect'
        },
        404: {
            'description': 'Utilisateur non trouvé'
        }
    }
})
def changer_mot_de_passe():
    data = request.json
    cin = data.get('cin')
    mot_de_passe_actuel = data.get('mot_de_passe_actuel')
    nouveau_mot_de_passe = data.get('nouveau_mot_de_passe')

    conn, cursor = get_cursor_and_connection()
    cursor.execute("SELECT cin, password FROM employee WHERE cin = %s", (cin,))
    user = cursor.fetchone()
    close_connection(conn, cursor)

    if user and check_password_hash(user[1], mot_de_passe_actuel):
        nouveau_mot_de_passe_hash = generate_password_hash(nouveau_mot_de_passe)
        conn, cursor = get_cursor_and_connection()
        cursor.execute("UPDATE employee SET password = %s WHERE cin = %s", (nouveau_mot_de_passe_hash, cin))
        conn.commit()
        close_connection(conn, cursor)
        return jsonify(message="Mot de passe changé avec succès"), 200
    elif user:
        return jsonify(message="Mot de passe actuel incorrect"), 401
    else:
        return jsonify(message="Utilisateur non trouvé"), 404

"""
@app.route('/notify_question_added', methods=['GET'])
def notify_question_added(id,msg):
    data = request.json  # Les données que vous envoyez depuis Flutter
    user_id = id
    message = msg

    # Ici, vous pouvez appeler une fonction pour envoyer la notification à l'utilisateur correspondant

    return jsonify({'message': 'new question : ' + message})


@app.route('/envoyer_question', methods=['POST'])
def envoyer_question():
    data = request.json
    employee_id = data.get('employee_id')
    question_text = data.get('question_text')

    conn, cursor = get_cursor_and_connection()
    cursor.execute("INSERT INTO inquiries (employee_id, question_text) VALUES (%s, %s)", (employee_id, question_text))
    conn.commit()
    close_connection(conn, cursor)
    notify_question_added(employee_id,question_text)
    return jsonify(message="Question envoyée avec succès"), 201
"""

@app.route('/envoyer_question', methods=['POST'])
def envoyer_question():
    data = request.json
    employee_id = data.get('employee_id')
    question_text = data.get('question_text')

    conn, cursor = get_cursor_and_connection()
    cursor.execute("INSERT INTO inquiries (employee_id, question_text) VALUES (%s, %s)", (employee_id, question_text))
    conn.commit()
    close_connection(conn, cursor)
    notification()
    return jsonify(message="Question envoyée avec succès"), 201

@app.route('/notification', methods=['GET'])
def notification():
    conn, cursor = get_cursor_and_connection()
    cursor.execute(
        "SELECT e.cin, e.email, e.lastname, e.firstname, e.image, i.question_text, i.id, i.timestamp "
        "FROM employee e "
        "LEFT JOIN inquiries i ON e.id = i.employee_id "
        "WHERE i.question_text IS NOT NULL "
        "ORDER BY i.id DESC "
        "LIMIT 5"  # Limit the results to the top 5 rows
    )
    employees_messages = cursor.fetchall()
    close_connection(conn, cursor)

    employee_messages_list = []
    for emp_msg in employees_messages:
        emp_msg_dict = {
            'cin': emp_msg[0],
            'email': emp_msg[1],
            'nom': emp_msg[2],
            'prenom': emp_msg[3],
            'image': emp_msg[4],
            'messages': [emp_msg[5] if emp_msg[5] else None],
            'id': emp_msg[6],
            'timestamp': emp_msg[7]
        }
        employee_messages_list.append(emp_msg_dict)
        """
        response_messages = []
        for emp_msg in employee_messages_list:
            response_messages.append({
                'name': f"{emp_msg['nom']} {emp_msg['prenom']}",
                'timestamp': emp_msg['timestamp'],
                'message': emp_msg['messages'][0],
                'image': emp_msg['image']  # Include the image URL here
        })

    return jsonify(response_messages)
"""
    response_messages = []
    for emp_msg in employee_messages_list:
        response_messages.append(f"{emp_msg['nom']} {emp_msg['prenom']} \n send message at {emp_msg['timestamp']}")

    return jsonify(employee_messages_list)


@app.route('/afficher_employees_messages', methods=['GET'])
@swag_from({
    'tags': ['Employees'],
    'summary': 'Afficher la liste des employés et leurs messages',
    'responses': {
        200: {
            'description': 'Liste des employés et leurs messages récupérée avec succès',
            'schema': {
                'type': 'array',
                'items': {
                    'type': 'object',
                    'properties': {
                        'cin': {'type': 'string'},
                        'email': {'type': 'string'},
                        'nom': {'type': 'string'},
                        'prenom': {'type': 'string'},
                        'role': {'type': 'string'},
                        'messages': {'type': 'array', 'items': {'type': 'string'}}
                    }
                }
            }
        }
    }
})
def afficher_employees_messages():
    conn, cursor = get_cursor_and_connection()
    cursor.execute("SELECT e.cin, e.email, e.lastname, e.firstname, e.image, i.question_text, i.id FROM employee e LEFT JOIN inquiries i ON e.id = i.employee_id WHERE i.question_text IS NOT NULL")
    employees_messages = cursor.fetchall()
    close_connection(conn, cursor)

    employee_messages_list = []
    for emp_msg in employees_messages:
        emp_msg_dict = {
            'cin': emp_msg[0],
            'email': emp_msg[1],
            'nom': emp_msg[2],
            'prenom': emp_msg[3],
            'image': emp_msg[4],
            'messages': [msg for msg in emp_msg[5:] if msg],
            'id': emp_msg[6]
        }
        employee_messages_list.append(emp_msg_dict)

    return jsonify(employee_messages_list)

@app.route('/enregistrer_reponse', methods=['POST'])
@swag_from({
    'tags': ['Employees'],
    'summary': 'Enregistrer une réponse pour une question',
    'parameters': [
        {
            'name': 'employee_id',
            'description': 'ID de l\'employé',
            'in': 'formData',
            'required': True,
            'type': 'integer'
        },
        {
            'name': 'question_id',
            'description': 'ID de la question',
            'in': 'formData',
            'required': True,
            'type': 'integer'
        },
        {
            'name': 'reponse_text',
            'description': 'Texte de la réponse',
            'in': 'formData',
            'required': True,
            'type': 'string'
        }
    ],
    'responses': {
        201: {
            'description': 'Réponse enregistrée avec succès',
            'schema': {
                'type': 'object',
                'properties': {
                    'message': {
                        'type': 'string'
                    }
                }
            }
        },
        404: {
            'description': 'Employé ou question non trouvé'
        }
    }
})
def enregistrer_reponse():
    data = request.json
    employee_id = data.get('employee_id')
    question_id = data.get('question_id')
    reponse_text = data.get('reponse_text')

    conn, cursor = get_cursor_and_connection()

    # Vérifier si l'employé existe
    cursor.execute("SELECT id FROM employee WHERE id = %s", (employee_id,))
    employee = cursor.fetchone()
    if not employee:
        close_connection(conn, cursor)
        return jsonify(message="Employé non trouvé"), 404

    # Vérifier si la question existe
    cursor.execute("SELECT id FROM inquiries WHERE id = %s", (question_id,))
    question = cursor.fetchone()
    if not question:
        close_connection(conn, cursor)
        return jsonify(message="Question non trouvée"), 404

    # Enregistrer la réponse
    cursor.execute("INSERT INTO answer (employee_id, question_id, reponse_text) VALUES (%s, %s, %s)",
                   (employee_id, question_id, reponse_text))
    conn.commit()
    close_connection(conn, cursor)
    notificationrep()
    return jsonify(message="Réponse enregistrée avec succès"), 201


@app.route('/notificationreponse', methods=['GET'])
def notificationrep():
    conn, cursor = get_cursor_and_connection()
    cursor.execute(
        "SELECT e.cin, e.email, e.lastname, e.firstname, e.image, a.reponse_text, a.id, a.created_at "
        "FROM employee e "
        "LEFT JOIN answer a ON e.id = a.employee_id "
        "WHERE a.reponse_text IS NOT NULL "
        "ORDER BY a.id DESC "
        "LIMIT 5"  # Limit the results to the top 5 rows
    )
    employees_messages = cursor.fetchall()
    close_connection(conn, cursor)

    employee_messages_list = []
    for emp_msg in employees_messages:
        emp_msg_dict = {
            'cin': emp_msg[0],
            'email': emp_msg[1],
            'nom': emp_msg[2],
            'prenom': emp_msg[3],
            'image': emp_msg[4],
            'messages': [emp_msg[5] if emp_msg[5] else None],
            'id': emp_msg[6],
            'created_at': emp_msg[7]
        }
        employee_messages_list.append(emp_msg_dict)
    response_messages = []
    for emp_msg in employee_messages_list:
        response_messages.append(f"{emp_msg['nom']} {emp_msg['prenom']} \n send response at {emp_msg['created_at']}")

    return jsonify(employee_messages_list)



@app.route('/afficher_reponses_employes/<int:question_id>', methods=['GET'])
@swag_from({
    'tags': ['Employees'],
    'summary': 'Afficher les réponses des employés pour une question donnée',
    'parameters': [
        {
            'name': 'question_id',
            'in': 'path',
            'type': 'integer',
            'required': True,
            'description': 'ID de la question pour filtrer les réponses'
        }
    ],
    'responses': {
        200: {
            'description': 'Réponses des employés récupérées avec succès',
            'schema': {
                'type': 'array',
                'items': {
                    'type': 'object',
                    'properties': {
                        'reponse_id': {'type': 'integer'},
                        'employee_cin': {'type': 'string'},
                        'employee_nom': {'type': 'string'},
                        'employee_prenom': {'type': 'string'},
                        'reponse_text': {'type': 'string'},
                        'reponse_created_at': {'type': 'string'}
                    }
                }
            }
        }
    }
})
def afficher_reponses_employes(question_id):
    conn, cursor = get_cursor_and_connection()

    # Jointure entre les tables "answer" et "employee" avec filtrage par ID de la question
    query = """
        SELECT a.id AS reponse_id, e.cin AS employee_cin, e.lastname AS employee_nom,
               e.firstname AS employee_prenom, e.image AS employee_image, a.reponse_text, a.created_at AS reponse_created_at
        FROM answer a
        INNER JOIN employee e ON a.employee_id = e.id
        WHERE a.question_id = %s
    """
    cursor.execute(query, (question_id,))
    reponses_employes = cursor.fetchall()
    close_connection(conn, cursor)

    reponses_list = []
    for reponse in reponses_employes:
        reponse_dict = {
            'reponse_id': reponse[0],
            'employee_cin': reponse[1],
            'employee_nom': reponse[2],
            'employee_prenom': reponse[3],
            'employee_image': reponse[4],
            'reponse_text': reponse[5],
            'reponse_created_at': reponse[6].strftime('%Y-%m-%d %H:%M:%S')
        }
        reponses_list.append(reponse_dict)

    return jsonify(reponses_list)

@app.route('/enregistrer_evaluation', methods=['POST'])
@swag_from({
    'tags': ['Evaluations'],
    'summary': 'Enregistrer l\'évaluation d\'un employé',
    'parameters': [
        {
            'name': 'employee_id',
            'description': 'ID de l\'employé',
            'in': 'formData',
            'required': True,
            'type': 'integer'
        },
        {
            'name': 'stars',
            'description': 'Nombre d\'étoiles (de 1 à 5)',
            'in': 'formData',
            'required': True,
            'type': 'integer'
        }
    ],
    'responses': {
        201: {
            'description': 'Évaluation enregistrée avec succès',
            'schema': {
                'type': 'object',
                'properties': {
                    'message': {
                        'type': 'string'
                    }
                }
            }
        },
        400: {
            'description': 'Nombre d\'étoiles invalide'
        }
    }
})
def enregistrer_evaluation():
    data = request.json
    employee_id = data.get('employee_id')
    stars = data.get('stars')

    if stars not in [1, 2, 3, 4, 5]:
        return jsonify({"message": "Nombre d'étoiles invalide"}), 400

    conn, cursor = get_cursor_and_connection()
    cursor.execute("INSERT INTO evaluation (employee_id, stars) VALUES (%s, %s)", (employee_id, stars))
    conn.commit()
    close_connection(conn, cursor)

    return jsonify({"message": "Évaluation enregistrée avec succès"}), 201

@app.route('/get_evaluations', methods=['GET'])
def get_evaluations():
    conn, cursor = get_cursor_and_connection()
    cursor.execute("SELECT stars FROM evaluation")
    evaluation_data = cursor.fetchall()
    close_connection(conn, cursor)

    return jsonify({"evaluations": evaluation_data})

@app.route('/get_employee_id', methods=['POST'])
def get_employee_id():
    data = request.json
    cin = data.get('cin')
    email = data.get('email')

    conn, cursor = get_cursor_and_connection()

    if cin:
        cursor.execute("SELECT id FROM employee WHERE cin = %s", (cin,))
    elif email:
        cursor.execute("SELECT id FROM employee WHERE email = %s", (email,))
    else:
        close_connection(conn, cursor)
        return jsonify({"message": "Fournissez soit le numéro CIN, soit l'email de l'employé"}), 400

    employee_id = cursor.fetchone()
    close_connection(conn, cursor)

    if employee_id:
        return jsonify({"id": employee_id[0]}), 200
    else:
        return jsonify({"message": "Employé non trouvé"}), 404

@app.route('/verif', methods=['POST'])
def verif():
    data = request.json
    email = data.get('email')

    conn, cursor = get_cursor_and_connection()
    cursor.execute("SELECT cin, email, password, lastname, firstname, role, image, id FROM employee WHERE email = %s", (email))
    user = cursor.fetchone()
    close_connection(conn, cursor)

    if user:
        session['user'] = {
            'cin': user[0],
            'email': user[1],
            'nom': user[4],
            'prenom': user[3],
            'role': user[5],
            'image': user[6],
            'id': user[7]
        }
        return jsonify(session['user']), 200
    else:
        return jsonify("Identifiants invalides"), 405
    
@app.route('/ajouter_projet', methods=['POST'])
@swag_from({
    'tags': ['Projects'],
    'summary': 'Ajouter un nouveau projet',
    'parameters': [
        {
            'name': 'date_debut',
            'description': 'Date de début du projet',
            'in': 'formData',
            'required': True,
            'type': 'string'  # You can adjust the data type as needed
        },
        {
            'name': 'date_fin',
            'description': 'Date de fin du projet',
            'in': 'formData',
            'required': True,
            'type': 'string'  # You can adjust the data type as needed
        },
        {
            'name': 'sujet',
            'description': 'Sujet du projet',
            'in': 'formData',
            'required': True,
            'type': 'string'
        },
        {
            'name': 'ingenieurs',
            'description': 'Liste des ingénieurs affectés (liste de CINs)',
            'in': 'formData',
            'required': True,
            'type': 'array',
            'items': {
                'type': 'string'
            }
        }
    ],
    'responses': {
        201: {
            'description': 'Projet enregistré avec succès',
            'schema': {
                'type': 'object',
                'properties': {
                    'message': {
                        'type': 'string'
                    }
                }
            }
        },
        400: {
            'description': 'Erreur lors de l\'enregistrement du projet'
        }
    }
})
def ajouter_projet():
    data = request.json
    date_debut = data.get('date_debut')
    date_fin = data.get('date_fin')
    sujet = data.get('sujet')
    employees = data.get('employees')

    try:
        conn, cursor = get_cursor_and_connection()
        cursor.execute("INSERT INTO projet (date_debut, date_fin, sujet) VALUES (%s, %s, %s)",
                       (date_debut, date_fin, sujet))
        projet_id = cursor.lastrowid

        for employee in employees:
            cursor.execute("INSERT INTO projet_ingenieur (projet_id, employee_id) VALUES (%s, %s)",
                           (projet_id, employee))

        conn.commit()
        close_connection(conn, cursor)
        return jsonify({"message": "Projet enregistré avec succès!", "id": projet_id}), 201
    except Exception as e:
        return jsonify(error=str(e)), 400


@app.route('/liste_employees', methods=['GET'])
def liste_employees():
    conn, cursor = get_cursor_and_connection()
    cursor.execute("SELECT id, lastname, firstname,image FROM employee")
    employees = cursor.fetchall()
    close_connection(conn, cursor)

    employee_list = []
    for emp in employees:
        emp_dict = {
            'id': emp[0],
            'lastname': emp[1],
            'firstname': emp[2],
            'image': emp[3]

        }
        employee_list.append(emp_dict)

    return jsonify(employee_list)

@app.route('/ajouter_tache', methods=['POST'])
@swag_from({
    'tags': ['Tasks'],
    'summary': 'Ajouter une nouvelle tâche pour un projet et un employé',
    'parameters': [
        {
            'name': 'projet_id',
            'description': 'ID du projet auquel la tâche est associée',
            'in': 'formData',
            'required': True,
            'type': 'integer'
        },
        {
            'name': 'employee_id',
            'description': 'ID de l\'employé auquel la tâche est assignée',
            'in': 'formData',
            'required': True,
            'type': 'integer'
        },
        {
            'name': 'description',
            'description': 'Description de la tâche',
            'in': 'formData',
            'required': True,
            'type': 'string'
        }
    ],
    'responses': {
        201: {
            'description': 'Tâche enregistrée avec succès',
            'schema': {
                'type': 'object',
                'properties': {
                    'message': {
                        'type': 'string'
                    }
                }
            }
        },
        400: {
            'description': 'Erreur lors de l\'enregistrement de la tâche'
        }
    }
})
def ajouter_tache():
    data = request.json
    projet_id = data.get('projet_id')
    employee_id = data.get('employee_id')
    date_debut = data.get('date_debut')
    date_fin = data.get('date_fin')
    description = data.get('description')
    date_creation = datetime.date.today()  # Date de création actuelle

    try:
        conn, cursor = get_cursor_and_connection()

        # Vérifier si l'employé est associé au projet
        cursor.execute("SELECT * FROM projet_ingenieur WHERE projet_id = %s AND employee_id = %s", (projet_id, employee_id))
        relation_exists = cursor.fetchone()

        if not relation_exists:
            return jsonify({"message": "L'employé n'est pas associé à ce projet."}), 400

        cursor.execute("INSERT INTO tache (projet_id, employee_id, date_debut, date_fin, description, date_creation) VALUES (%s, %s, %s, %s, %s, %s)",
                       (projet_id, employee_id, date_debut, date_fin, description, date_creation))

        conn.commit()
        close_connection(conn, cursor)
        return jsonify({"message": "Tâche enregistrée avec succès!"}), 201
    except Exception as e:
        return jsonify(error=str(e)), 400
@app.route('/afficher_taches_par_employee/<string:employee_cin>', methods=['GET'])
def afficher_taches_par_employee(employee_cin):
    conn, cursor = get_cursor_and_connection()

    # Récupérer les tâches et projets associés à l'employé
    cursor.execute("SELECT projet.sujet, tache.id, tache.description, tache.date_debut, tache.date_fin "
                   "FROM projet "
                   "JOIN tache ON tache.projet_id = projet.id "
                   "WHERE tache.employee_id = (SELECT id FROM employee WHERE cin = %s)", (employee_cin,))
    
    tasks_and_projects = cursor.fetchall()
    close_connection(conn, cursor)

    if tasks_and_projects:
        result = []
        current_project = None
        current_tasks = []

        for project, task_id, task, date_debut, date_fin in tasks_and_projects:
            if project != current_project:
                if current_project:
                    result.append({'projet_sujet': current_project, 'taches': current_tasks})
                current_project = project
                current_tasks = []

            current_tasks.append({'tache_id': task_id, 'tache_description': task, 'tache_date_debut': date_debut, 'tache_date_fin': date_fin})

        if current_project:
            result.append({'projet_sujet': current_project, 'taches': current_tasks})

        return jsonify({'taches_projets': result}), 200
    else:
        return jsonify({"message": "Employé non trouvé ou non associé à des tâches ou des projets"}), 404
    
@app.route('/enregistrer_tache_terminee/<int:tache_id>', methods=['GET','POST'])
def enregistrer_tache_terminee(tache_id):
    try:
        conn, cursor = get_cursor_and_connection()

        # Récupérer les détails de la tâche
        cursor.execute("SELECT * FROM tache WHERE id = %s", (tache_id,))
        tache = cursor.fetchone()

        if tache:
            projet_id = tache[1]
            employee_id = tache[2]
            date_debut = tache[3]
            date_fin = tache[4]
            description = tache[5]
            date_creation = datetime.datetime.now().date()  # Utilise la date d'aujourd'hui

            # Insérer la tâche terminée dans la table "done"
            cursor.execute("INSERT INTO done (projet_id, employee_id, date_debut, date_fin, description, date_creation) "
                           "VALUES (%s, %s, %s, %s, %s, %s)",
                           (projet_id, employee_id, date_debut, date_fin, description, date_creation))
            
            # Supprimer la tâche de la table "tache"
            cursor.execute("DELETE FROM tache WHERE id = %s", (tache_id,))
            
            conn.commit()
            close_connection(conn, cursor)
            return jsonify({"message": "Tâche enregistrée comme terminée et supprimée de la liste des tâches."}), 200
        else:
            return jsonify({"message": "Tâche non trouvée"}), 404
    except Exception as e:
        return jsonify(error=str(e)), 500


@app.route('/afficher_taches_terminees', methods=['GET'])
def afficher_taches_terminees():
    try:
        conn, cursor = get_cursor_and_connection()

        # Récupérer les tâches terminées depuis la table "done"
        cursor.execute("SELECT * FROM done")
        taches_terminees = cursor.fetchall()

        # Convertir les résultats en une liste de dictionnaires pour une représentation JSON
        taches_terminees_list = []
        for tache in taches_terminees:
            tache_dict = {
                'id': tache[0],
                'projet_id': tache[1],
                'employee_id': tache[2],
                'date_debut': tache[3].isoformat(),
                'date_fin': tache[4].isoformat(),
                'description': tache[5],
                'date_creation': tache[6].isoformat()
            }
            taches_terminees_list.append(tache_dict)

        close_connection(conn, cursor)
        return jsonify(taches_terminees_list), 200
    except Exception as e:
        return jsonify(error=str(e)), 500

if __name__ == '__main__':
    app.run(debug=True)