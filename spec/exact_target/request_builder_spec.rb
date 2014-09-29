require 'spec_helper'

describe ExactTarget::RequestBuilder do
  subject { ExactTarget::RequestBuilder.new(ExactTarget::Configuration.new) }

  describe '#bulk_async_retrieve_subscriber_statuses' do
    it 'returns the correct XML' do
      xml = %q(
<system>
<system_name>subscriber</system_name>
<action>BulkAsync</action>
<sub_action>SubsStatus_ToFTP</sub_action>
<search_type>lid</search_type>
<search_value>1</search_value>
</system>).gsub(%r(\n), '')
      expect(subject.bulk_async_retrieve_subscriber_statuses(1)).to match(xml)
    end
  end
end
