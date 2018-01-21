email     = shell.ask 'Which email do you want use for logging into admin?'
password  = shell.ask 'Tell me the password to use:'

shell.say ''

account = Account.create(email: email, password: password, password_confirmation: password, role: 'admin')

if account.valid?
  shell.say '================================================================='
  shell.say 'Account has been successfully created, now you can login with:'
  shell.say '================================================================='
  shell.say "   email: #{email}"
  shell.say "   password: #{password}"
  shell.say '================================================================='
else
  shell.say 'Sorry but some thing went wrong!'
  account.errors.full_messages.each { |m| shell.say "   - #{m}" }
end
