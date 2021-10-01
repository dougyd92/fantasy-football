# for use with the table_print gem
module ColumnFormatter
  def self.decimal(column_name, sig_figs)
    { column_name => { display_method: lambda { |data|
                                         format("%.#{sig_figs}f", data[column_name]).rjust(sig_figs + 3)
                                       }, fixed_width: [sig_figs + 3, column_name.length].max } }
  end
end
