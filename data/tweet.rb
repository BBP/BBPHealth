require 'csv'
CSV.foreach("data/tweet.csv", :headers => true, :header_converters => :symbol) do |row|
  # puts row[:from_user]
  # puts row[:geo_coordinates].gsub('loc: ', "").split(",").map &:to_f
  # puts row[:drugs]
  email = "#{row[:from_user]}@twitter_import.com".downcase
  user = User.where(email: email).first
  if user.nil?
    password = Devise.friendly_token[0,20]
    user = User.create!(email: email, password: password, password_confirmation: password)

  end
  drug = row[:drugs].downcase
  medication = Medication.where(name: drug).first
  coords = row[:geo_coordinates].gsub('loc: ', "").split(",").map &:to_f

  if medication.nil?
    medication = Medication.new(name: drug, experience: row[:text], lat: coords.first, lng: coords.last)
    medication.user = user
    medication.save!
  else
    medication.prescriptions.create!(experience: row[:text], lat: coords.first, lng: coords.last, user: user)
  end
end
