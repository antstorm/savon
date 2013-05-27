require 'spec_helper'

describe Wasabi::Operation do

  describe '#input' do
    context 'with an rpc/literal wsdl' do
      let(:wsdl) { Wasabi.new fixture(:rpc_literal).read }

      it 'handles a single part with a @type attribute' do
        input = wsdl.operation('SampleService', 'Sample', 'op1').input

        expect(input.count).to eq(1)

        # notice how the parts don't include the wrapper element for rpc calls.
        # this is nothing we need to show the user, so we're handling it later.

        expect(input.first.to_a).to eq([
           [['in'],          { namespace: nil,                        form: 'unqualified' }],
           [['in', 'data1'], { namespace: 'http://dataNamespace.com', form: 'unqualified', type: 'int' }],
           [['in', 'data2'], { namespace: 'http://dataNamespace.com', form: 'unqualified', type: 'int' }]
        ])
      end

      it 'handles parts referencing top-level @elements and elements with a @ref' do
        input = wsdl.operation('SampleService', 'Sample', 'op3').input

        expect(input.count).to eq(2)

        # part@type (and element@ref)
        data_elem = input.first

        expect(data_elem.to_a).to eq([
          [['DataElem'],          { namespace: 'http://dataNamespace.com', form: 'qualified' }],
          [['DataElem', 'data1'], { namespace: 'http://dataNamespace.com', form: 'unqualified', type: 'int' }],
          [['DataElem', 'data2'], { namespace: 'http://dataNamespace.com', form: 'unqualified', type: 'int' }]
        ])

        # part@element
        in2 = input.last

        expect(in2.to_a).to eq([
          [['in2'], { namespace: nil, form: 'unqualified' }],
          [['in2', 'RefDataElem'], { namespace: 'http://refNamespace.com', form: 'qualified', type: 'int' }]
        ])
      end
    end

    context 'with a document/literal wsdl' do
      let(:wsdl) { Wasabi.new fixture(:document_literal_wrapped).read }

      it 'handles a simple wrapped operation' do
        input = wsdl.operation('SampleService', 'Sample', 'op1').input

        expect(input.count).to eq(1)

        expect(input.first.to_a).to eq([
          [['op1'],                { namespace: 'http://apiNamespace.com',  form: 'qualified' }],
          [['op1', 'in'],          { namespace: 'http://apiNamespace.com',  form: 'unqualified' }],
          [['op1', 'in', 'data1'], { namespace: 'http://dataNamespace.com', form: 'unqualified', type: 'int' }],
          [['op1', 'in', 'data2'], { namespace: 'http://dataNamespace.com', form: 'unqualified', type: 'int' }]
        ])
      end

      it 'finds namespaces defined on specific schemas' do
        input = wsdl.operation('SampleService', 'Sample', 'op3').input

        expect(input.count).to eq(1)

        expect(input.first.to_a).to eq([
          [['op3'],                       { namespace: 'http://apiNamespace.com',  form: 'qualified' }],
          [['op3', 'DataElem'],           { namespace: 'http://dataNamespace.com', form: 'qualified' }],
          [['op3', 'DataElem', 'data1'],  { namespace: 'http://dataNamespace.com', form: 'unqualified', type: 'int' }],
          [['op3', 'DataElem', 'data2'],  { namespace: 'http://dataNamespace.com', form: 'unqualified', type: 'int' }],
          [['op3', 'in2'],                { namespace: 'http://apiNamespace.com',  form: 'unqualified' }],
          [['op3', 'in2', 'RefDataElem'], { namespace: 'http://refNamespace.com',  form: 'qualified',   type: 'int' }]
        ])
      end
    end
  end

end
