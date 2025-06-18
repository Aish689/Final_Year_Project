import firebase_admin
from firebase_admin import credentials, firestore

# Step 1: Initialize Firestore
def initialize_firestore():
    try:
        cred = credentials.Certificate(r"E:\AI Powered system\perfomance_prediction\myProject_file.json")
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("✅ Firestore initialized successfully!")
        return db
    except Exception as e:
        print(f"❌ Error initializing Firestore: {e}")
        return None

# Step 2: Add userId field to all staff documents
def add_user_ids_to_staff(db):
    try:
        print("🔍 Fetching staff documents...")
        staff_ref = db.collection('staff')
        staff_docs = staff_ref.stream()

        updated_count = 0

        for doc in staff_docs:
            doc_id = doc.id
            doc_ref = staff_ref.document(doc_id)
            doc_data = doc.to_dict()

            # Check if 'userId' already exists
            if 'userId' not in doc_data:
                # Update document with userId
                doc_ref.update({'userId': doc_id})
                print(f"✅ userId added for document: {doc_id}")
                updated_count += 1
            else:
                print(f"ℹ️ userId already exists for document: {doc_id}")

        print(f"\n🎯 Total documents updated: {updated_count}")

    except Exception as e:
        print(f"❌ Error updating staff documents: {e}")

# Step 3: Main Runner
if __name__ == "__main__":
    db = initialize_firestore()
    if db:
        add_user_ids_to_staff(db)
