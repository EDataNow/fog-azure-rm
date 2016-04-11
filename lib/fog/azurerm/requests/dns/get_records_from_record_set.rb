module Fog
  module DNS
    class AzureRM
      class Real
        def get_records_from_record_set(record_set_name, dns_resource_group, zone_name, record_type)
          resource_url = "#{AZURE_RESOURCE}/subscriptions/#{@subscription_id}/resourceGroups/#{dns_resource_group}/providers/Microsoft.Network/dnsZones/#{zone_name}/#{record_type}/#{record_set_name}?api-version=2015-05-04-preview"
          puts "Getting all records from RecordSet #{record_set_name} of type '#{record_type}' in zone #{zone_name}"

          token = Fog::Credentials::AzureRM.get_token(@tenant_id, @client_id, @client_secret)
          existing_records = Array.new
          begin
            dns_response = RestClient.get(
                resource_url,
                accept: 'application/json',
                content_type: 'application/json',
                authorization: token
            )
          rescue Exception => e
            if e.http_code == 404
              puts 'AzureDns::RecordSet - 404 code, record set does not exist.  returning empty array'
              return existing_records
            else
              puts "Exception trying to get existing #{record_type} records for the record set: #{record_set_name}"
              msg = "AzureDns::RecordSet - Exception is: #{e.message}"
              fail msg
            end
          end

          begin
            dns_hash = JSON.parse(dns_response)
            case record_type
              when 'A'
                dns_hash['properties']['ARecords'].each do |record|
                  puts "AzureDns:RecordSet - A record is: #{record}"
                  existing_records.push(record['ipv4Address'])
                end
              when 'CNAME'
                puts "AzureDns:RecordSet - CNAME record is: #{dns_hash['properties']['CNAMERecord']['cname']}"
                existing_records.push(dns_hash['properties']['CNAMERecord']['cname'])
            end
            return existing_records
          rescue Exception => e
            puts "Exception trying to parse response: #{dns_response}"
            msg = "AzureDns::RecordSet - Exception is: #{e.message}"
            fail msg
          end
        end
      end

      class Mock
        def get_records_from_record_set(record_set_name, dns_resource_group, zone_name, record_type)

        end
      end
    end
  end
end