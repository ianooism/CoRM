class AddUserRelation < ActiveRecord::Migration
  
  @element = Hash[
      "events" => [
        "created_by",
        "modified_by"
      ],
      "accounts" => [
        "created_by",
        "modified_by"
      ],
      "contacts" => [
        "created_by",
        "modified_by"
      ],
      "documents" => [
        "created_by",
        "updated_by"
      ],
      "opportunities" => [
        "created_by",
        "updated_by"
      ],
      "quotations" => [
        "created_by",
        "updated_by"
      ],
      "origins" => [
        "created_by",
        "updated_by"
      ],
      "tags" => [
        "created_by",
        "updated_by"
      ],
      "tasks" => [
        "created_by",
        "updated_by"
      ],
    ]
  
  def up
    
    # modified_by objects
    
    changeTablesUp(Event, :created_by)
    changeTablesUp(Event, :modified_by)
    
    changeTablesUp(Account, :created_by)
    changeTablesUp(Account, :modified_by)
    
    changeTablesUp(Contact, :created_by)
    changeTablesUp(Contact, :modified_by)
    
    # updated_by objects
    
    changeTablesUp(Document, :created_by)
    changeTablesUp(Document, :updated_by)
    
    changeTablesUp(Opportunity, :created_by)
    changeTablesUp(Opportunity, :updated_by)
    
    changeTablesUp(Origin, :created_by)
    changeTablesUp(Origin, :updated_by)
    
    changeTablesUp(Quotation, :created_by)
    changeTablesUp(Quotation, :updated_by)
    
    changeTablesUp(Tag, :created_by)
    changeTablesUp(Tag, :updated_by)
    
    changeTablesUp(Task, :created_by)
    changeTablesUp(Task, :updated_by)
    
    @elements.each do |table_name, table|
      table.each do |column|
        changeTableType(table_name, column, "string", "integer")
        addFK(table_name, column)
      end
    end
  end

  def down
    # Drop foreign key
    # ALTER TABLE
    @element.each { |table_name, table|
      table.each { |column|
        remFK(table_name, column)
        changeTableType(table_name, column, "integer", "string")
      }
    
    }

    @elements.each do |table_name, table|
      table.each do |column|
        remFK(table_name, column)
        changeTableType(table_name, column, "integer", "string")
      end
    end
    
    # modified_by objects
    
    changeTablesDown(Event, :created_by)
    changeTablesDown(Event, :modified_by)
    
    changeTablesDown(Account, :created_by)
    changeTablesDown(Account, :modified_by)
    
    changeTablesDown(Contact, :created_by)
    changeTablesDown(Contact, :modified_by)
    
    # updated_by objects
    
    changeTablesDown(Document, :created_by)
    changeTablesDown(Document, :updated_by)
    
    changeTablesDown(Opportunity, :created_by)
    changeTablesDown(Opportunity, :updated_by)
    
    changeTablesDown(Origin, :created_by)
    changeTablesDown(Origin, :updated_by)
    
    changeTablesDown(Quotation, :created_by)
    changeTablesDown(Quotation, :updated_by)
    
    changeTablesDown(Tag, :created_by)
    changeTablesDown(Tag, :updated_by)
    
    changeTablesDown(Task, :created_by)
    changeTablesDown(Task, :updated_by)
    
  end
  
  ##
  # 
  #
  def changeTablesUp(o, field)
    class_name = o.new.class.name
    logger.info("BEGIN on #{class_name}")
    o.all.each do |value|
      names = value[field].blank?  ? '' : value[field].split(' ')
      # if the Array/String length > 0, then add it to the users array with line key
      if names.length > 0
        currentUser = User.where({ :surname => names[1], :forename => names[0] }).first()
        if currentUser.nil?
          currentUser = User.where({ :surname => names[0], :forename => names[1] }).first()
        end
        if !currentUser.nil?
          logger.info("Change #{class_name}.#{field} from #{currentUser.full_name} to #{currentUser.id.to_s}")
          value.update_attributes({ field => currentUser.id.to_s })
        else
          logger.info('The current User does not exist or table field is not filled')
        end
      end
    end
    
  end
  
  ##
  # 
  #
  def changeTablesDown(o, field)
    i = 0
    o.all.each do |value|
      id = value[field]
      i += 1
      # if the Array/String length > 0, then add it to the users array with line key
      if !id.blank?
        currentUser = User.find(id)
        if !currentUser.nil?
          logger.info("Change #{o.class.name}.#{field} from #{currentUser.id.to_s} to #{currentUser.full_name}")
          value.update_attributes({ field => currentUser.full_name })
        else
          logger.info('The current User does not exist or table field is not filled')
        end
      end
    end
    return i
  end
  
  def changeTableType(table, column, old_type, type)
    logger.info("Change table #{table} with column #{column} type was #{old_type} and is now #{type}")
    if (type == 'string')
      type = 'varchar(255)'
    end
    
    query = "ALTER TABLE #{table} ALTER COLUMN #{column} TYPE #{type}"
    if (type == 'integer' && old_type == 'string')
      query.concat(" USING (trim(#{column})::integer)")
    end  
    execute(query)
  end
  
  def addFK(table, column)
    query = "ALTER TABLE #{table} ADD CONSTRAINT \"fk_users_#{table}_#{column}\" FOREIGN KEY (#{column}) REFERENCES users(id);"
    execute(query)
  end
  
  def remFK(table, column)
    execute "ALTER TABLE #{table} DROP CONSTRAINT \"fk_users_#{table}_#{column}\";"
  end
end