json.extract! public_guest, :id, :fullname, :email, :created_at, :updated_at
json.url public_guest_url(public_guest, format: :json)
