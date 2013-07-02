package de.wwu.md2.framework.generator.ios

import de.wwu.md2.framework.generator.util.DataContainer
import de.wwu.md2.framework.mD2.ActionDef
import de.wwu.md2.framework.mD2.ActionReference
import de.wwu.md2.framework.mD2.AllowedOperation
import de.wwu.md2.framework.mD2.AssignObjectAtContentProviderAction
import de.wwu.md2.framework.mD2.CallTask
import de.wwu.md2.framework.mD2.ConditionalEventRef
import de.wwu.md2.framework.mD2.CustomAction
import de.wwu.md2.framework.mD2.CustomCodeFragment
import de.wwu.md2.framework.mD2.CustomizedValidatorType
import de.wwu.md2.framework.mD2.DataAction
import de.wwu.md2.framework.mD2.ElementEventType
import de.wwu.md2.framework.mD2.EventBindingTask
import de.wwu.md2.framework.mD2.EventDef
import de.wwu.md2.framework.mD2.EventUnbindTask
import de.wwu.md2.framework.mD2.GPSUpdateAction
import de.wwu.md2.framework.mD2.GlobalEventRef
import de.wwu.md2.framework.mD2.GlobalEventType
import de.wwu.md2.framework.mD2.GotoNextWorkflowStepAction
import de.wwu.md2.framework.mD2.GotoPreviousWorkflowStepAction
import de.wwu.md2.framework.mD2.GotoViewAction
import de.wwu.md2.framework.mD2.GotoWorkflowStepAction
import de.wwu.md2.framework.mD2.MappingTask
import de.wwu.md2.framework.mD2.NewObjectAtContentProviderAction
import de.wwu.md2.framework.mD2.RemoteValidator
import de.wwu.md2.framework.mD2.SetActiveWorkflowAction
import de.wwu.md2.framework.mD2.SimpleAction
import de.wwu.md2.framework.mD2.SimpleActionRef
import de.wwu.md2.framework.mD2.StandardIsDateValidator
import de.wwu.md2.framework.mD2.StandardIsIntValidator
import de.wwu.md2.framework.mD2.StandardIsNumberValidator
import de.wwu.md2.framework.mD2.StandardNotNullValidator
import de.wwu.md2.framework.mD2.StandardNumberRangeValidator
import de.wwu.md2.framework.mD2.StandardRegExValidator
import de.wwu.md2.framework.mD2.StandardStringRangeValidator
import de.wwu.md2.framework.mD2.StandardValidator
import de.wwu.md2.framework.mD2.StandardValidatorType
import de.wwu.md2.framework.mD2.UnmappingTask
import de.wwu.md2.framework.mD2.ValidatorBindingTask
import de.wwu.md2.framework.mD2.ValidatorMaxLengthParam
import de.wwu.md2.framework.mD2.ValidatorMaxParam
import de.wwu.md2.framework.mD2.ValidatorMessageParam
import de.wwu.md2.framework.mD2.ValidatorMinLengthParam
import de.wwu.md2.framework.mD2.ValidatorMinParam
import de.wwu.md2.framework.mD2.ValidatorRegExParam
import de.wwu.md2.framework.mD2.ValidatorType
import de.wwu.md2.framework.mD2.ValidatorUnbindTask
import de.wwu.md2.framework.mD2.ViewElementEventRef
import de.wwu.md2.framework.mD2.WorkflowStep
import java.util.Date
import java.util.List
import java.util.Set

import static de.wwu.md2.framework.generator.util.MD2GeneratorUtil.*

class ActionClass
{
	private DataContainer dataContainer
	new(DataContainer dataContainer)
	{
		this.dataContainer = dataContainer
	}
	
	def createCustomActionH(CustomAction action) '''
		//
		//  «action.name.toFirstUpper»Action.h
		//
		//  Generated by MD2 framework on «new Date()».
		//  Copyright (c) 2012 Uni-Muenster. All rights reserved.
		//
		
		#import "«IOSGenerator::md2LibraryImport»/Action.h"
		
		@interface «action.name.toFirstUpper»Action : Action
		@end'''
	
	def createCustomActionM(CustomAction action) '''
		//
		//  «action.name.toFirstUpper»Action.m
		//
		//  Generated by MD2 framework on «new Date()».
		//  Copyright (c) 2012 Uni-Muenster. All rights reserved.
		//
		
		#import "SpecificAppData.h"
		#import "«IOSGenerator::md2LibraryImport»/EventBindingAction.h"
		#import "«IOSGenerator::md2LibraryImport»/EventTrigger.h"
		#import "«IOSGenerator::md2LibraryImport»/RegisterMappingAction.h"
		#import "«IOSGenerator::md2LibraryImport»/UnregisterMappingAction.h"
		#import "«IOSGenerator::md2LibraryImport»/ValidatorBindingAction.h"
		#import "«IOSGenerator::md2LibraryImport»/ViewEvent.h"
		#import "«action.name.toFirstUpper»Action.h"
		«FOR name : getAllActionPaths(action.codeFragments)»
			#import "«name».h"
		«ENDFOR»
		«FOR name : getAllValidatorPaths(action.codeFragments)»
			#import "«name».h"
		«ENDFOR»
		«FOR name : getImportEvents(action.codeFragments)»
			#import "«name».h"
		«ENDFOR»
		
		@implementation «action.name.toFirstUpper»Action

		+(void) performAction: (Event *) event
		{
			[self performCustomAction];
		}
		
		+(void) performCustomAction
		{
			«FOR fragment : action.codeFragments»
				«generateCodeFragment(fragment)»
			«ENDFOR»
		}
		
		@end'''
	
	def createWorkflowStepActionH(WorkflowStep workflowStep, String eventType) '''
		//
		//  «workflowStep.name.toFirstUpper + eventType»WorkflowStepAction.h
		//
		//  Generated by MD2 framework on «new Date()».
		//  Copyright (c) 2012 Uni-Muenster. All rights reserved.
		//
		
		#import "«IOSGenerator::md2LibraryImport»/Action.h"

		@interface «workflowStep.name.toFirstUpper + eventType»WorkflowStepAction : Action
		@end'''
	
	def createWorkflowStepActionM(WorkflowStep workflowStep, String eventType) '''
		//
		//  «workflowStep.name.toFirstUpper + eventType»WorkflowStepAction.m
		//
		//  Generated by MD2 framework on «new Date()».
		//  Copyright (c) 2012 Uni-Muenster. All rights reserved.
		//
		
		#import "SpecificAppData.h"
		#import "«IOSGenerator::md2LibraryImport»/EventTrigger.h"
		#import "«IOSGenerator::md2LibraryImport»/EventBindingAction.h"
		#import "«IOSGenerator::md2LibraryImport»/GotoPreviousWorkflowStepAction.h"
		#import "«IOSGenerator::md2LibraryImport»/GotoNextWorkflowStepAction.h"
		#import "«workflowStep.name.toFirstUpper + eventType»WorkflowStepAction.h"

		@implementation «workflowStep.name.toFirstUpper + eventType»WorkflowStepAction

		+(void) performAction: (Event *) event
		{
			[self performCustomAction];
		}
		
		+(void) performCustomAction
		{
			«IF !workflowStep.backwardEvents.empty»
				«FOR event : workflowStep.backwardEvents»
					«generateCodeFragment(event, "[GotoPreviousWorkflowStepAction action]")»
				«ENDFOR»
			«ENDIF»
			«IF !workflowStep.forwardEvents.empty»
				«FOR event : workflowStep.forwardEvents»
					«generateCodeFragment(event, "[GotoNextWorkflowStepAction action]")»
				«ENDFOR»
			«ENDIF»
		}
		
		@end'''
	
	////////////////////////////////////////////////////////////////
	/// Generate code fragments (Actions)
	////////////////////////////////////////////////////////////////
	
	def dispatch generateCodeFragment(EventBindingTask task) '''
		«FOR action : task.actions»
			«FOR event : task.events»
				«IF event instanceof ViewElementEventRef»
					[EventBindingAction performAction: [EventBindingEvent eventWithMapping: [AppData eventActionMapping] viewEvent: [ViewEvent eventWithIdentifier: @"«getEventIdentifier(event)»" eventType: «getEventType(event)»] action: «getAction(action)»]];
				«ELSE»
					[EventBindingAction performAction: [EventBindingEvent eventWithMapping: [AppData eventActionMapping] action: «getAction(action)»]];
				«ENDIF»
			«ENDFOR»
		«ENDFOR»
	'''
	
	def dispatch generateCodeFragment(EventUnbindTask task) '''
		«FOR action : task.actions»
			«FOR event : task.events»
				«IF event instanceof ViewElementEventRef»
					[EventUnbindingAction performAction: [AppData eventActionMapping] triggerIdentifier: @"«getEventIdentifier(event)»" eventType: «getEventType(event)»];
				«ELSE»
					[EventUnbindingAction performAction: [AppData eventActionMapping] triggeringEventClass: [«getEventIdentifier(event).toFirstUpper» class]];
				«ENDIF»
			«ENDFOR»
		«ENDFOR»
	'''
	
	def dispatch generateCodeFragment(ValidatorBindingTask task) '''
		«FOR validator : task.validators»
			«FOR input : task.referencedFields»
				«IF validator instanceof StandardValidatorType && getViewOfGUIElement(dataContainer.viewContainers, resolveViewGUIElement(input)) != null»
					[ValidatorBindingAction performAction: [ValidatorBindingEvent eventWithController: [SpecificAppData «getName(getViewOfGUIElement(dataContainer.viewContainers, resolveViewGUIElement(input))).toFirstLower»Controller] validator: «getValidator(validator)» identifier: @"«getName(resolveViewGUIElement(input)).toFirstLower»"]];
				«ENDIF»
			«ENDFOR»
		«ENDFOR»
	'''
	
	def dispatch generateCodeFragment(ValidatorUnbindTask task) '''
		«FOR validator : task.validators»
			«FOR input : task.referencedFields»
				«IF validator instanceof StandardValidatorType && getViewOfGUIElement(dataContainer.viewContainers, resolveViewGUIElement(input)) != null»
					[ValidatorUnbindingAction performAction: [ValidatorUnbindingEvent eventWithController: [SpecificAppData «getName(getViewOfGUIElement(dataContainer.viewContainers, resolveViewGUIElement(input))).toFirstLower»Controller] validator: «getValidator(validator)» identifier: @"«getName(resolveViewGUIElement(input)).toFirstLower»"]];
				«ENDIF»
			«ENDFOR»
		«ENDFOR»
	'''
	
	def dispatch generateCodeFragment(CallTask task)
	{
		if(task.action instanceof ActionReference)
		{
			'''[«(task.action as ActionReference).actionRef.name.toFirstUpper»Action performCustomAction];'''
		}
		else
		{
			// else we have a simple Action
			var SimpleAction action = (task.action as SimpleActionRef).action
			switch action
			{
				GotoNextWorkflowStepAction: '''[GotoNextWorkflowStepAction performAction: [[GotoNextWorkflowStepEvent alloc] init]];'''
				GotoPreviousWorkflowStepAction: '''[GotoPreviousWorkflowStepAction performAction: [[GotoPreviousWorkflowStepEvent alloc] init]];'''
				GotoWorkflowStepAction: '''[GotoWorkflowStepAction performAction: [GotoWorkflowStepEvent eventWithWorkflowStepName: @"«action.wfStep.name»"]];'''
				GotoViewAction: '''[GotoControllerAction performAction: [GotoControllerEvent eventWithWindow: [AppData window] tabBarController: [AppData tabBarController] currentController: [AppData currentController] nextController: [SpecificAppData «getName(resolveViewGUIElement(action.view)).toFirstLower»Controller]]];'''
				DataAction:
				{
					switch (action as DataAction).operation
					{
						case AllowedOperation::CREATE_OR_UPDATE: '''[PersistAction performAction: [PersistEvent eventWithContentProvider: [SpecificAppData «action.contentProvider.name.toFirstLower»ContentProvider]]];'''
						case AllowedOperation::READ: '''[LoadAction performAction: [LoadEvent eventWithContentProvider: [SpecificAppData «action.contentProvider.name.toFirstLower»ContentProvider]]];'''
						case AllowedOperation::DELETE: '''[RemoveAction performAction: [RemoveEvent eventWithContentProvider: [SpecificAppData «action.contentProvider.name.toFirstLower»ContentProvider]]];'''
					}
				}
				GPSUpdateAction: '''
					[GPSUpdateAction performAction: [GPSUpdateEvent eventWithBindings:
						[NSArray arrayWithObjects: 
							«FOR binding : (action as GPSUpdateAction).bindings»
								[GPSActionBinding bindingWithContentProvider: [SpecificAppData «binding.path.contentProviderRef.name.toFirstLower»ContentProvider] dataKey: @"«getPathTailAsString(binding.path.tail)»"
									formattedString: @"«binding.entries.map[entry | if(entry.gpsField != null) '%@' else entry.string].join»"
									identifiers: [NSArray arrayWithObjects: «binding.entries.filter[gpsField != null].map['''@"«gpsField.literal»", '''].join»nil]],
							«ENDFOR»
							nil]]];
					'''
				NewObjectAtContentProviderAction: '''[CreateAction performAction: [CreateEvent eventWithContentProvider: [SpecificAppData «action.contentProvider.name.toFirstLower»ContentProvider]]];'''
				AssignObjectAtContentProviderAction: '''[AssignObjectAtContentProviderAction performAction: [AssignObjectAtContentProviderEvent eventWithBindings: [NSDictionary dictionaryWithObjectsAndKeys: «FOR binding : action.bindings»[SpecificAppData «binding.contentProvider.name.toFirstLower»ContentProvider], @"«getPathTailAsString(binding.path.tail)»", «ENDFOR»nil]]];'''
				SetActiveWorkflowAction: '''[GotoWorkflowAction performAction: [GotoWorkflowEvent eventWithWorkflowName: @"«action.workflow.name.toFirstLower»Workflow"]];'''
			}
		}
	}
	
	// TODO get attribute from content provider
	def dispatch generateCodeFragment(MappingTask task) '''
		«IF getViewOfGUIElement(dataContainer.viewContainers, resolveViewGUIElement(task.referencedViewField)) != null»
			[RegisterMappingAction performAction: [RegisterMappingEvent eventWithDataMapper: [SpecificAppData «getName(getViewOfGUIElement(dataContainer.viewContainers, resolveViewGUIElement(task.referencedViewField))).toFirstLower»Controller].dataMapper contentProvider: [SpecificAppData «task.pathDefinition.contentProviderRef.name.toFirstLower»ContentProvider] dataKey: @"«getPathTailAsString(task.pathDefinition.tail)»" identifier: @"«getName(resolveViewGUIElement(task.referencedViewField))»"]];
		«ENDIF»
	'''
	
	def dispatch generateCodeFragment(UnmappingTask task) '''
		«IF getViewOfGUIElement(dataContainer.viewContainers, resolveViewGUIElement(task.referencedViewField)) != null»
			[UnregisterMappingAction performAction: [UnregisterMappingEvent eventWithDataMapper: [SpecificAppData «getName(getViewOfGUIElement(dataContainer.viewContainers, resolveViewGUIElement(task.referencedViewField))).toFirstLower»Controller].dataMapper identifier: @"«getName(resolveViewGUIElement(task.referencedViewField))»"]];
		«ENDIF»
	'''
	
	////////////////////////////////////////////////////////////////
	/// Generate code fragments (WorkflowStepActions)
	////////////////////////////////////////////////////////////////
	
	def generateCodeFragment(EventDef event, String action) '''
		«IF event instanceof ViewElementEventRef»
			[EventBindingAction performAction: [EventBindingEvent eventWithMapping: [AppData eventActionMapping] viewEvent: [ViewEvent eventWithIdentifier: @"«getEventIdentifier(event)»" eventType: «getEventType(event)»] action: «action»]];
		«ELSE»
			[EventBindingAction performAction: [EventBindingEvent eventWithMapping: [AppData eventActionMapping] action: «action»]];
		«ENDIF»
	'''
	
	////////////////////////////////////////////////////////////////
	/// Helper
	////////////////////////////////////////////////////////////////
	
	def private getEventIdentifier(EventDef event)
	{
		switch event
		{
			ViewElementEventRef: getName(resolveViewGUIElement(event.referencedField)).toFirstLower
			GlobalEventRef:
			{
				if (event == GlobalEventType::CONNECTION_LOST)
					"" //TODO
			}
			ConditionalEventRef: event.eventReference.name.toFirstUpper + "OnConditionEvent"
		}
	}
	
	def private getEventType(EventDef event)
	{
		switch event
		{
			ViewElementEventRef:
			{
				switch event.event
				{
					case ElementEventType::ON_TOUCH: "OnTouch"
					case ElementEventType::ON_LEFT_SWIPE: "LeftSwipe"
					case ElementEventType::ON_RIGHT_SWIPE: "RightSwipe"
					case ElementEventType::ON_WRONG_VALIDATION: 0 //TODO
				}
			}
		}
	}
	
	def private getActionClassPath(ActionDef action)
	{
		switch action
		{
			ActionReference: action.actionRef.name.toFirstUpper + "Action"
			SimpleActionRef:
			{
				val a = action.action
				// static files -> add library part to path
				IOSGenerator::md2LibraryImport + "/" + switch a
				{
					GotoNextWorkflowStepAction: "GotoNextWorkflowStepAction"
					GotoPreviousWorkflowStepAction: "GotoPreviousWorkflowStepAction"
					GotoWorkflowStepAction: "GotoWorkflowStepAction"
					GotoViewAction: "GotoControllerAction"
					DataAction:
					{
						switch a.operation
						{
							case AllowedOperation::CREATE_OR_UPDATE: "PersistAction"
							case AllowedOperation::READ: "LoadAction"
							case AllowedOperation::DELETE: "RemoveAction"
						}
					}
					GPSUpdateAction: "GPSUpdateAction"
					NewObjectAtContentProviderAction: "CreateAction"
					AssignObjectAtContentProviderAction: "AssignObjectAtContentProviderAction"
					SetActiveWorkflowAction: "GotoWorkflowAction"
				}
			}
		}
	}
	
	def private getAllActionPaths(List<CustomCodeFragment> fragments)
	{
		val Set<String> result = newHashSet
		for(fragment : fragments)
		{
			switch fragment
			{
				EventBindingTask: fragment.actions.forEach [actionDef | result.add(getActionClassPath(actionDef))]
				EventUnbindTask: fragment.actions.forEach [actionDef | result.add(getActionClassPath(actionDef))]
				CallTask: result.add(getActionClassPath(fragment.action))
			}
		}
		result
	}
	
	def private getAllValidatorPaths(List<CustomCodeFragment> fragments)
	{
		val Set<String> result = newHashSet
		for(fragment : fragments)
		{
			switch fragment
			{
				ValidatorBindingTask: fragment.validators.forEach [validator | result.add(getValidatorPath(validator))]
				ValidatorUnbindTask: fragment.validators.forEach [validator | result.add(getValidatorPath(validator))]
			}
		}
		result.remove(null)
		result
	}
	
	def private getValidatorPath(ValidatorType validator)
	{
		// all validators are static
		IOSGenerator::md2LibraryImport + "/" + 
		// we are only interested in the standard validators here
		// => the customized validators were replaced by parametrized standard validators during preprocessing (M2M)
		if(validator instanceof StandardValidatorType)
		{
			val StandardValidator standardValidator = (validator as StandardValidatorType).validator
			switch standardValidator
			{
				StandardIsIntValidator: "IntegerValidator"
				StandardNotNullValidator: "NotEmptyValidator"
				StandardIsNumberValidator: "FloatValidator"
				StandardIsDateValidator: "Validator"
				StandardRegExValidator: "RegExValidator"
				StandardNumberRangeValidator: "NumberRangeValidator"
				StandardStringRangeValidator: "StringRangeValidator"
			}
		}
		else if (validator instanceof CustomizedValidatorType)
		{
			val CustomizedValidatorType customizedValidatorType = (validator as CustomizedValidatorType)
			switch customizedValidatorType
			{
				RemoteValidator: "RemoteValidator"
			}
		}
	}
	
	def private getValidator(ValidatorType validator)
	{
		if(validator instanceof StandardValidatorType)
		{
			val StandardValidator standardValidator = (validator as StandardValidatorType).validator
			val message = standardValidator.params.filter(typeof(ValidatorMessageParam)).last?.message
			switch standardValidator
			{
				StandardIsIntValidator:
				{
					if(message == null) '''[[IntegerValidator alloc] init]'''
					else '''[[IntegerValidator alloc] initWithMessage: @"«message»"]'''
				}
				StandardNotNullValidator:
				{
					if(message == null) '''[[NotEmptyValidator alloc] init]'''
					else '''[[NotEmptyValidator alloc] initWithMessage: @"«message»"]'''
				}
				StandardIsNumberValidator:
				{
					if(message == null) '''[[FloatValidator alloc] init]'''
					else '''[[FloatValidator alloc] initWithMessage: @"«message»"]'''
				}
				StandardIsDateValidator:
				{
					'''[[Validator alloc] init]''' // TODO
				}
				StandardRegExValidator:
				{
					val regEx = standardValidator.params.filter(typeof(ValidatorRegExParam)).last.regEx
					if(message == null) '''[[RegExValidator alloc] initWithPattern: @"«regEx»"]'''
					else '''[[RegExValidator alloc] initWithPattern: @"«regEx»" message: @"«message»"]'''
				}
				StandardNumberRangeValidator:
				{
					val max = standardValidator.params.filter(typeof(ValidatorMaxParam)).last
					val min = standardValidator.params.filter(typeof(ValidatorMinParam)).last
					val maxStr = if(max == null) "FLT_MAX" else max.max
					val minStr = if(min == null) "FLT_MIN" else min.min
						
					if(message == null) '''[[NumberRangeValidator alloc] initWithMinimum: «minStr» maximum: «maxStr»]'''
					else '''[[NumberRangeValidator alloc] initWithMinimum: «minStr» maximum: «maxStr» message: @"«message»"]'''
				}
				StandardStringRangeValidator:
				{
					val max = standardValidator.params.filter(typeof(ValidatorMaxLengthParam)).last
					val min = standardValidator.params.filter(typeof(ValidatorMinLengthParam)).last
					val maxStr = if(max == null) "INT_MAX" else max.maxLength
					val minStr = if(min == null) "0" else min.minLength
						
					if(message == null) '''[[StringRangeValidator alloc] initWithMinimum: «minStr» maximum: «maxStr»]'''
					else '''[[StringRangeValidator alloc] initWithMinimum: «minStr» maximum: «maxStr» message: @"«message»"]'''
				}
			}
		}
		else if (validator instanceof CustomizedValidatorType)
		{
			val CustomizedValidatorType customizedValidatorType = (validator as CustomizedValidatorType)
			switch customizedValidatorType
			{
				RemoteValidator: '''[[RemoteValidator alloc] initWithName: «customizedValidatorType.name.toFirstLower» remoteURL: «customizedValidatorType.connection.uri» contentProvider: «customizedValidatorType.contentProvider.name.toFirstUpper»ContentProvider attributes: [NSArray arrayWithObjects:«FOR attribute : customizedValidatorType.provideAttributes»«getPathTailAsString(attribute.tail)», «ENDFOR»nil]]'''
			}
		}
	}
	
	def private static getImportEvents(List<CustomCodeFragment> fragments)
	{
		val Set<ActionDef> actions = newHashSet
		val Set<String> result = newHashSet
		
		for(fragment : fragments)
		{
			switch fragment
			{
				EventBindingTask: fragment.actions.forEach [actionDef | actions.add(actionDef)]
				EventUnbindTask: fragment.actions.forEach [actionDef | actions.add(actionDef)]
				CallTask: actions.add(fragment.action)
			}
		}
		for(actionDef : actions)
		{
			if(actionDef instanceof SimpleActionRef)
			{
				val action = (actionDef as SimpleActionRef).action
				result.add(switch action
				{
					GotoWorkflowStepAction: "GotoWorkflowStepEvent"
					GotoWorkflowStepAction: "GotoControllerEvent"
					DataAction: switch action.operation
					{
							case AllowedOperation::CREATE_OR_UPDATE: "PersistEvent"
							case AllowedOperation::READ: "LoadEvent"
							case AllowedOperation::DELETE: "RemoveEvent"
					}
					GPSUpdateAction: "GPSUpdateEvent"
					NewObjectAtContentProviderAction: "CreateEvent"
					AssignObjectAtContentProviderAction: "AssignObjectAtContentProviderEvent"
					SetActiveWorkflowAction: "GotoWorkflowEvent"
					default: null
				})
			}
		}
		// prefix non-empty entries with library path
		result.filterNull.map[IOSGenerator::md2LibraryImport + "/" + it]
	}
	
	def private static getAction(ActionDef actionDef)
	{
		if(actionDef instanceof SimpleActionRef)
		{
			val action = (actionDef as SimpleActionRef).action
			switch action
			{
				GotoNextWorkflowStepAction: '''[GotoNextWorkflowStepAction action]'''
				GotoPreviousWorkflowStepAction: '''[GotoPreviousWorkflowStepAction action]'''
				GotoWorkflowStepAction: '''[GotoWorkflowStepAction actionWithEvent: [GotoWorkflowStepEvent eventWithWorkflowStepName: @"«action.wfStep.name»"]]'''
				GotoViewAction: '''[GotoControllerAction actionWithEvent: [GotoControllerEvent eventWithWindow: [AppData window] tabBarController: [AppData tabBarController] currentController: [AppData currentController] nextController: [SpecificAppData «getName(resolveViewGUIElement(action.view)).toFirstLower»Controller]]]'''
				DataAction:
				{
					var operation = action.operation
					switch operation
					{
						case AllowedOperation::CREATE_OR_UPDATE: '''[PersistAction actionWithEvent: [PersistEvent eventWithContentProvider: [SpecificAppData «action.contentProvider.name.toFirstLower»ContentProvider]]]'''
						case AllowedOperation::READ: '''[LoadAction actionWithEvent: [LoadEvent eventWithContentProvider: [SpecificAppData «action.contentProvider.name.toFirstLower»ContentProvider]]]'''
						case AllowedOperation::DELETE: '''[RemoveAction actionWithEvent: [RemoveEvent eventWithContentProvider: [SpecificAppData «action.contentProvider.name.toFirstLower»ContentProvider]]]'''
					}
				}
				GPSUpdateAction: '''[GPSUpdateAction actionWithEvent: [GPSUpdateEvent eventWithBindings: [NSArray arrayWithObjects: «FOR binding : (action as GPSUpdateAction).bindings»[GPSActionBinding bindingWithContentProvider: [SpecificAppData «binding.path.contentProviderRef.name.toFirstLower»ContentProvider] dataKey: @"«getPathTailAsString(binding.path.tail)»" formattedString: @"«FOR entry : binding.entries»«IF entry.gpsField != null»%@«ELSE»«entry.string»«ENDIF»«ENDFOR»" identifiers: [NSArray arrayWithObjects: «FOR entry : binding.entries»«IF entry.gpsField != null»@"«entry.gpsField.literal»", «ENDIF»«ENDFOR»nil]]«ENDFOR», nil]]]'''
				NewObjectAtContentProviderAction: '''[CreateAction actionWithEvent: [CreateEvent eventWithContentProvider: [SpecificAppData «action.contentProvider.name.toFirstLower»ContentProvider]]]'''
				AssignObjectAtContentProviderAction: '''[AssignObjectAtContentProviderAction actionWithEvent: [AssignObjectAtContentProviderEvent eventWithBindings: [NSDictionary dictionaryWithObjectsAndKeys: «FOR binding : action.bindings»[SpecificAppData «binding.contentProvider.name.toFirstLower»ContentProvider], «getPathTailAsString(binding.path.tail)», «ENDFOR»nil]]]'''
				SetActiveWorkflowAction: '''[GotoWorkflowAction actionWithEvent: [GotoWorkflowEvent eventWithWorkflowName: @"«action.workflow.name.toFirstLower»Workflow"]]'''
			}
		}
		else
		{
			'''[«(actionDef as ActionReference).actionRef.name.toFirstUpper»Action action]'''
		}
	}
}