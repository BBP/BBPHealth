require 'spec_helper'

describe User do
  [:email, :password, :password_confirmation, :remember_me].each do |param|
    it { should allow_mass_assignment_of(param) }
  end
end
