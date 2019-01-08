class ImportAssociationMap
  def initialize
    @import_association_map = []
  end

  def add_association(old_record, new_record, type)
    @import_association_map << {old_record: old_record, new_record: new_record, type: type}
  end

  def get_by_old_id(id, type)
    result = @import_association_map.select { |entry| entry[:type] == type && entry[:old_record]['id'] == id }
    if result[0]
      result[0][:new_record]
    else
      # puts "Notice: entry of id #{id} and type #{type} does not exist. Perhaps it is deleted?"
    end
  end
end