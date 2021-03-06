require 'spec_helper'

describe Qualtrics::Panel, :vcr => true  do
  it 'has a name' do
    name = 'New Panel'
    panel = Qualtrics::Panel.new({
      name: name
    })
    expect(panel.name).to eq(name)
  end

  it 'has a category' do
    category = 'Amazing Category'
    panel = Qualtrics::Panel.new({
      category: category
    })
    expect(panel.category).to eq(category)
  end

  it 'has a library id' do
    library_id = '1'
    panel = Qualtrics::Panel.new({
      library_id: library_id
    })
    expect(panel.library_id).to eq(library_id)
  end

  it 'defaults to the configured library id when none is specified' do
    panel = Qualtrics::Panel.new
    expect(panel.library_id).to eq(Qualtrics.configuration.default_library_id)
  end

  let(:panel) do
    Qualtrics::Panel.new({
      name: 'Newest Panel',
      category: 'Great Category'
    })
  end

  context 'creating to qualtrics' do
    before(:each) do
      Qualtrics.begin_transaction!
    end

    after(:each) do
      Qualtrics.rollback_transaction!
    end

    it 'persists to qualtrics' do
      expect(panel.save).to be true
    end

    it 'populates the panel_id when successful' do
      panel.save
      expect(panel.id).to_not be_nil
    end

    it 'populates the success attribute' do
      panel.save
      expect(panel).to be_success
    end
  end

  it 'raises an error when you attempt to save an already presisted panel' do
    panel.name = 'An Even Newer Panel'
    expect(panel.save).to be true
    panel.name = 'The new newest panel.'
    expect(lambda{ panel.save }).to raise_error Qualtrics::UpdateNotAllowed
  end

  it 'destroys a panel that returns true when successful' do
    panel.save
    expect(panel.destroy).to be true
  end

  it 'retrieves an array of all panels in a library' do
    panel.save
    expect(Qualtrics::Panel.all.map{|p| p.id}).to include(panel.id)
  end

  context 'updating in qualtrics' do
    it 'adds recipients to an existing panel' do
      panel.save
      expect(panel.persisted?).to be true
      recipients = [
        Qualtrics::Recipient.new(email: 'example@example.com', first_name: 'New', last_name: 'Person'),
        Qualtrics::Recipient.new(email: 'example@example.com', first_name: 'Another', last_name: 'NewPerson')
      ]
      expect(panel.add_recipients(recipients)).to be true
    end
  end
end
