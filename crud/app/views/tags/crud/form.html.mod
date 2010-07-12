%{
    if(_object) {
        currentObject = _object
        currentType = _('controllers.CRUD$ObjectType').forClass(_object.getClass().getName())
    } else if(_class) {
        currentObject = null;
        currentType = _('controllers.CRUD$ObjectType').forClass(_class)
    } else {
        currentObject = _caller.object
        currentType = _caller.type
    }
    
	// Eval fields tags
	def fieldsHandler = [:]
	if(_body) {
		_body.setProperty('fieldsHandler', fieldsHandler);
		_body.toString(); // we skeep the real result ...
	}
}%

#{list items:_fields ?: currentType.fields*.name, as:'fieldName'}

	%{
	   am = ''
	   def field = currentType.getField(fieldName)
       def showField = true
     }%



	%{ if(fieldsHandler[fieldName]) { }%
        <div class="crudField crud_${field.type}">
		%{
			def handler = fieldsHandler[fieldName]
			handler.setProperty('fieldName', 'object.' + field?.name + (field?.type == 'relation' ? '@id' : ''))
            def oldObject = handler.getProperty('object')
			handler.setProperty('object', currentObject)
			out.println(handler.toString())
			handler.setProperty('object', oldObject)
			handler.setProperty('fieldName', null)
		}%
        </div>
	%{ } else { }%
	    #{if field.type != 'unknown'}
            %{ showField = false }%

            <div class="crudField crud_${field.type}">

                #{ifnot field}
                    %{ throw new play.exceptions.TagInternalException('Field not found -> ' + fieldName) }%
                #{/ifnot}

                #{if field.type == 'text'}
                    #{crud.textField name:field.name, value:(currentObject ? currentObject[field.name] : null) /}
                #{/if}

                #{if field.type == 'password'}
                    #{crud.passwordField name:field.name, value:(currentObject ? currentObject[field.name] : null) /}
                #{/if}

                #{if field.type == 'file'}
                    #{crud.fileField name:field.name, value:(currentObject ? currentObject[field.name] : null), id:currentObject?.id /}
                #{/if}

                #{if field.type == 'longtext'}
                    #{crud.longtextField name:field.name, value:(currentObject ? currentObject[field.name] : null) /}
                #{/if}

                #{if field.type == 'number'}
                    #{crud.numberField name:field.name, value:(currentObject ? currentObject[field.name] : null) /}
                    %{ am = 'crud.help.numeric' }%
                #{/if}

                #{if field.type == 'date'}
                    #{crud.dateField name:field.name, value:(currentObject ? currentObject[field.name] : null) /}
                    %{ am = 'crud.help.dateformat' }%
                #{/if}

                #{if field.type == 'relation'}
                    #{crud.relationField name:field.name, value:(currentObject ? currentObject[field.name] : null), field:field /}
                #{/if}

                #{if field.type == 'boolean'}
                    #{crud.checkField name:field.name, value:(currentObject ? currentObject[field.name] : null) /}
                #{/if}

                #{if field.type == 'enum'}
                    #{crud.enumField name:field.name, value:(currentObject ? currentObject[field.name] : null), property:field /}
                #{/if}

                #{if field.type == 'serializedText'}
                    #{crud.textField name:field.name, value:(currentObject ? controllers.CRUD.collectionSerializer(currentObject[field.name]) : null), property:field /}
                #{/if}
				<!-- mod by ikeda 2010.07.12 -->
				#{if field.type == 'id'}
                    #{crud.idField_readonly name:field.name, value:(currentObject ? currentObject[field.name] : null) /}
                #{/if}
                <!-- mod by ikeda 2010.07.12 -->

                <span class="crudHelp">
                    &{am}
                        %{ play.data.validation.Validation.getValidators(currentType.entityClass, fieldName, 'object').each() { }%
                            %{
                                switch (it.annotation.annotationType().name.substring(21)) {
                                    case "Required":
                                        out.println(messages.get('crud.help.required'))
                                        break;
                                    case "MinSize":
                                        out.println(messages.get('crud.help.minlength', it.annotation.value()))
                                        break;
                                    case "MaxSize":
                                        out.println(messages.get('crud.help.maxlength', it.annotation.value()))
                                        break;
                                    case "Range":
                                        out.println(messages.get('crud.help.range', it.annotation.min(), it.annotation.max()))
                                        break;
                                    case "Min":
                                        out.println(messages.get('crud.help.min', it.annotation.value()))
                                        break;
                                    case "Email":
                                        out.println(messages.get('crud.help.email'))
                                        break;
                                    case "Equals":
                                        out.println(messages.get('crud.help.equals', it.params.equalsTo))
                                        break;
                                    case "Future":
                                        if(it.params.reference) {
                                            out.println(messages.get('crud.help.after', it.params.reference))
                                        } else {
                                            out.println(messages.get('crud.help.future'))
                                        }
                                        break;
                                    case "Past":
                                        if(it.params.reference) {
                                            out.println(messages.get('crud.help.before', it.params.reference))
                                        } else {
                                            out.println(messages.get('crud.help.past'))
                                        }
                                        break;
                                }
                            }%
                        %{ } }%
                </span>
            </div>
        #{/}
	%{ } }%

#{/list}
