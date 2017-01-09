require 'mechanize'
require 'csv'
require 'pony'

@loginpage = 'https://app.skuvault.com/account/login'

require_relative 'config'

FILENAME << ".csv"

SKUFILE = "SKU.txt"
#method to turn a file into a list (in this case, for SKUs)
def textToArray(filename)
  textfile = File.open(filename, 'r')
  filearr = textfile.to_a
  returnArr = []
  filearr.each do |item|
    returnArr.push(item.chomp)
  end
  return returnArr
end

SKULIST = textToArray(SKUFILE)


def sanitize(arrayRow)
  return arrayRow.values_at(0, 2, 7)
end
#Gather CSV file from SKUVault
agent = Mechanize.new

login_page = agent.get @loginpage
login_form = login_page.form
email_field = login_form.field_with(name: "Email")
password_field = login_form.field_with(name: "Password")

email_field.value = LOGIN
password_field.value = PASSWORD

page = login_form.submit

export_page = page.link_with(text: 'Exporting').click

export_form = export_page.form_with(action: "/admin/export/quantitybywarehouseexport")

enablezero = export_form.checkbox_with(name: "IncludeZeroQuantity")
enablezero.check

csv = export_form.submit.content

File.open(FILENAME, 'wb'){ | f | f << csv }

inventory = CSV.read(FILENAME)
inventoryCopy = inventory

CSV.open("#{Date.today.to_s}.csv", 'w') do |csv|
  csv_header = sanitize(inventoryCopy[0])
  csv << csv_header
  inventoryCopy.delete_at(0)

  inventoryCopy.each do |row|
    if SKULIST.include? row[0]
      csv << sanitize(row)
    end
  end

end

#Generate email to send report
time = Time.now
Pony.mail({
  :to => EMAIL_TO,
  :cc => EMAIL_CC,
  :from => EMAIL_FROM,
  :sender => EMAIL_SENDER,
  :subject => EMAIL_SUBJECT,
  :body => EMAIL_BODY,
  :attachments => {"#{EMAIL_ATTACH_PREFIX}-#{Date.today.to_s}.csv" => File.read("#{Date.today.to_s}.csv")},
  :via => :smtp,
  :via_options => {
    :address              => 'smtp.gmail.com',
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => EMAIL_USERNAME,
    :password             => EMAIL_PASS,
    :authentication       => :login, # :plain, :login, :cram_md5, no auth by default
    :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
  }
})
