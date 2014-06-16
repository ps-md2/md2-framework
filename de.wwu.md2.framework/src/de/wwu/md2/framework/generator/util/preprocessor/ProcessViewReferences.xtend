package de.wwu.md2.framework.generator.util.preprocessor

import de.wwu.md2.framework.mD2.AbstractViewGUIElementRef
import de.wwu.md2.framework.mD2.AlternativesPane
import de.wwu.md2.framework.mD2.AutoGeneratedContentElement
import de.wwu.md2.framework.mD2.ContainerElement
import de.wwu.md2.framework.mD2.ContainerElementRef
import de.wwu.md2.framework.mD2.ContainerElementType
import de.wwu.md2.framework.mD2.CustomAction
import de.wwu.md2.framework.mD2.CustomCodeFragment
import de.wwu.md2.framework.mD2.ElseCodeBlock
import de.wwu.md2.framework.mD2.EventBindingTask
import de.wwu.md2.framework.mD2.EventUnbindTask
import de.wwu.md2.framework.mD2.FlowLayoutPane
import de.wwu.md2.framework.mD2.GridLayoutPane
import de.wwu.md2.framework.mD2.IfCodeBlock
import de.wwu.md2.framework.mD2.MD2Factory
import de.wwu.md2.framework.mD2.MappingTask
import de.wwu.md2.framework.mD2.SimpleType
import de.wwu.md2.framework.mD2.StyleBody
import de.wwu.md2.framework.mD2.StyleReference
import de.wwu.md2.framework.mD2.TabSpecificParam
import de.wwu.md2.framework.mD2.UnmappingTask
import de.wwu.md2.framework.mD2.ValidatorBindingTask
import de.wwu.md2.framework.mD2.ValidatorUnbindTask
import de.wwu.md2.framework.mD2.ViewElementEventRef
import de.wwu.md2.framework.mD2.ViewElementRef
import de.wwu.md2.framework.mD2.ViewElementType
import de.wwu.md2.framework.mD2.ViewGUIElement
import java.util.Collection
import java.util.HashMap
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider

import static de.wwu.md2.framework.generator.util.preprocessor.ProcessAutoGenerator.*
import static de.wwu.md2.framework.generator.util.preprocessor.Util.*

import static extension de.wwu.md2.framework.generator.util.MD2GeneratorUtil.*
import static extension org.eclipse.emf.ecore.util.EcoreUtil.*

class ProcessViewReferences {
	
	/**
	 * Clone nested ContainerElement references into parent container.
	 */
	def static void cloneContainerElementReferencesIntoParentContainer(
		MD2Factory factory, ResourceSet workingInput,
		HashMap<EObject, EObject> clonedElements, Iterable<ContainerElementRef> containerRefs
	) {
		containerRefs.forEach [ containerRef |
			val containerDef = factory.createContainerElementDef()
			containerDef.value = copyElement(containerRef.value, clonedElements) as ContainerElement
			if (containerRef.rename) containerDef.value.name = containerRef.name
			containerRef.params.forEach [ param |
				val newParam = copyElement(param) as TabSpecificParam
				switch (containerDef.value) {
					GridLayoutPane: (containerDef.value as GridLayoutPane).params.add(newParam)
					FlowLayoutPane: (containerDef.value as FlowLayoutPane).params.add(newParam)
					AlternativesPane: (containerDef.value as AlternativesPane).params.add(newParam)
				}
			]
			val EList<EObject> elements = containerRef.eContainer.eGet(containerRef.eContainingFeature) as EList<EObject>
			elements.add(elements.indexOf(containerRef), containerDef)
		]
	}
	
	/**
	 * Clone nested ViewElement references into parent container.
	 */
	def static void cloneViewElementReferencesIntoParentContainer(
		MD2Factory factory, ResourceSet workingInput, HashMap<EObject, EObject> clonedElements, Collection<ViewElementRef> viewRefsDone
	) {
		var repeat = true
		while (repeat) {
			val Iterable<ViewElementRef> viewRefs = workingInput.resources.map(r|r.allContents.toIterable.filter(typeof(ViewElementRef))).flatten.toList.sort(
				[obj1, obj2 |
					return countContainers(obj2,0)-countContainers(obj1,0)
				])
			val size = viewRefsDone.size 
			viewRefs.forEach [ viewRef |
				if (!viewRefsDone.contains(viewRef)) {
					val viewDef = factory.createViewElementDef()
					viewDef.value = copyElement(viewRef.value, clonedElements) as ViewGUIElement
					if (viewRef.rename) viewDef.value.name = viewRef.name
					val EList<EObject> elements = viewRef.eContainer.eGet(viewRef.eContainingFeature) as EList<EObject>
					elements.add(elements.indexOf(viewRef), viewDef)
					viewRefsDone.add(viewRef)
				}
			]
			// For the lack of mutable Booleans
			repeat = (viewRefsDone.size != size)
		}
	}
	
	/**
	 * Replace style reference with referenced style definition.
	 */
	def static void replaceStyleRefernces(MD2Factory factory, ResourceSet workingInput) {
		val styleRefs = workingInput.resources.map(r|r.allContents.toIterable.filter(typeof(StyleReference))).flatten.toList
		styleRefs.forEach[ styleRef |
			val styleDef = factory.createStyleDefinition()
			styleDef.definition = copyElement(styleRef.reference.body) as StyleBody
			styleRef.replace(styleDef)
		]
	}
	
	/**
	 * Simplify references to AbstractViewGUIElements (auto-generated and/or cloned)
	 * Set ViewGUIElement to head ref
	 */
	def static void simplifyReferencesToAbstractViewGUIElements(MD2Factory factory, ResourceSet workingInput, HashMap<EObject, EObject> clonedElements) {
		val Iterable<AbstractViewGUIElementRef> abstractRefs = workingInput.resources.map[ r |
			r.allContents.toIterable.filter(typeof(AbstractViewGUIElementRef)).filter([!(it.eContainer instanceof AbstractViewGUIElementRef)])
		].flatten
		
		abstractRefs.forEach[ abstractRef |
			abstractRef.ref = resolveAbstractViewGUIElementRef(workingInput, abstractRef, null, clonedElements)
			abstractRef.tail?.remove
			abstractRef.path?.remove
			abstractRef.simpleType?.remove
		]
	}
	
	/**
	 * Copy user-specified validators from original to cloned/auto-generated GUI elements.
	 * Restricted to StartupActions.
	 */
	def static void copyValidatorsToClonedGUIElements(
		MD2Factory factory, ResourceSet workingInput, HashMap<EObject,
		EObject> clonedElements, Collection<ValidatorBindingTask> userValidatorBindingTasks
	) {
		
		val Iterable<ValidatorBindingTask> validatorBindingTasks = workingInput.resources.map[r |
			r.allContents.toIterable.filter(typeof(ValidatorBindingTask)).filter([isCalledAtStartup(it)])
		].flatten.toList
		
		validatorBindingTasks.forEach [ validatorBindingTask |
			for (abstractRef : validatorBindingTask.referencedFields) {
				for (entry : clonedElements.entrySet) {
					if (entry.value == abstractRef.resolveViewGUIElement) {
						val newTask = copyElement(validatorBindingTask) as ValidatorBindingTask
						newTask.referencedFields.clear
						val newAbstractRef = factory.createAbstractViewGUIElementRef()
						newAbstractRef.ref = entry.key
						newTask.referencedFields.add(newAbstractRef)
						validatorBindingTask.eContainer.addCodeFragmentToParentCodeContainer(newTask)
						userValidatorBindingTasks.add(newTask)
					}
				}
			}
			userValidatorBindingTasks.add(validatorBindingTask)
		]
	}
	
	/**
	 * Copy user-specified events from original to cloned/auto-generated GUI elements.
	 * Restricted to StartupActions.
	 */
	def static void copyEventsToClonedGUIElements(MD2Factory factory, ResourceSet workingInput, HashMap<EObject, EObject> clonedElements) {
		val Iterable<EventBindingTask> eventBindingTasks = workingInput.resources.map[ r |
			r.allContents.toIterable.filter(typeof(EventBindingTask)).filter([isCalledAtStartup(it)])
		].flatten.toList
		
		eventBindingTasks.forEach[ eventBindingTask |
			eventBindingTask.events.filter(typeof(ViewElementEventRef)).forEach[ eventRef |
				for (entry : clonedElements.entrySet) {
					if (entry.value == eventRef.referencedField.resolveViewGUIElement) {
						val newTask = copyElement(eventBindingTask) as EventBindingTask
						newTask.events.clear
						val newEventRef = factory.createViewElementEventRef()
						val newAbstractRef = factory.createAbstractViewGUIElementRef()
						newAbstractRef.ref = entry.key
						newEventRef.referencedField = newAbstractRef
						newEventRef.event = eventRef.event
						newTask.events.add(newEventRef)
						eventBindingTask.eContainer.addCodeFragmentToParentCodeContainer(newTask)
					}
				}				
			]
		]
	}
	
	/**
	 * Copy all CustomCodeFragments from regular (non-startup) actions from original to cloned/auto-generated GUI elements.
	 * BEWARE: In the previous steps (remapToClonedGUIElements, copyValidatorsToClonedGUIElements, copyEventsToClonedGUIElements)
	 *         only the start action was considered. Now, all other actions are transformed.
	 */
	def static void copyAllCustomCodeFragmentsToClonedGUIElements(MD2Factory factory, ResourceSet workingInput, HashMap<EObject, EObject> clonedElements) {
		
		val Iterable<CustomCodeFragment> nonStartupCodeFragments = workingInput.resources.map[r |
			r.allContents.toIterable.filter(typeof(CustomCodeFragment)).filter([!isCalledAtStartup(it)])
		].flatten.toList
		
		nonStartupCodeFragments.forEach [ codeFragment |
			val codeFragmentAction = codeFragment.eContainer
			switch (codeFragment) {
				EventBindingTask: {
					codeFragment.events.filter(typeof(ViewElementEventRef)).forEach [ eventRef |
						for (entry : clonedElements.entrySet) {
							if (entry.value == eventRef.referencedField.resolveViewGUIElement) {
								val newTask = copyElement(codeFragment) as EventBindingTask
								newTask.events.clear
								val newEventRef = factory.createViewElementEventRef()
								val newAbstractRef = factory.createAbstractViewGUIElementRef()
								newAbstractRef.ref = entry.key
								newEventRef.referencedField = newAbstractRef
								newEventRef.event = eventRef.event
								newTask.events.add(newEventRef)
								codeFragmentAction.addCodeFragmentToParentCodeContainer(newTask)
							}
						}				
					]
				}
				EventUnbindTask: {
					codeFragment.events.filter(typeof(ViewElementEventRef)).forEach [ eventRef |
						for (entry : clonedElements.entrySet) {
							if (entry.value == eventRef.referencedField.resolveViewGUIElement) {
								val newTask = copyElement(codeFragment) as EventUnbindTask
								newTask.events.clear
								val newEventRef = factory.createViewElementEventRef()
								val newAbstractRef = factory.createAbstractViewGUIElementRef()
								newAbstractRef.ref = entry.key
								newEventRef.referencedField = newAbstractRef
								newEventRef.event = eventRef.event
								newTask.events.add(newEventRef)
								codeFragmentAction.addCodeFragmentToParentCodeContainer(newTask)
							}
						}				
					]
				}
				ValidatorBindingTask: {
					for (abstractRef : codeFragment.referencedFields) {
						for (entry : clonedElements.entrySet) {
							if (entry.value == abstractRef.resolveViewGUIElement) {
								val newTask = copyElement(codeFragment) as ValidatorBindingTask
								newTask.referencedFields.clear
								val newAbstractRef = factory.createAbstractViewGUIElementRef()
								newAbstractRef.ref = entry.key
								newTask.referencedFields.add(newAbstractRef)
								codeFragmentAction.addCodeFragmentToParentCodeContainer(newTask)
							}
						}
					}
				}
				ValidatorUnbindTask: {
					for (abstractRef : codeFragment.referencedFields) {
						for (entry : clonedElements.entrySet) {
							if (entry.value == abstractRef.resolveViewGUIElement) {
								val newTask = copyElement(codeFragment) as ValidatorUnbindTask
								newTask.referencedFields.clear
								val newAbstractRef = factory.createAbstractViewGUIElementRef()
								newAbstractRef.ref = entry.key
								newTask.referencedFields.add(newAbstractRef)
								codeFragmentAction.addCodeFragmentToParentCodeContainer(newTask)
							}
						}
					}
				}
				MappingTask: {
					for (entry : clonedElements.entrySet) {
						if (entry.value == codeFragment.referencedViewField.resolveViewGUIElement) {		
							val newTask = copyElement(codeFragment) as MappingTask
							val newAbstractRef = factory.createAbstractViewGUIElementRef()
							newAbstractRef.ref = entry.key
							newTask.referencedViewField = newAbstractRef
							codeFragmentAction.addCodeFragmentToParentCodeContainer(newTask)
						}
					}
				}
				UnmappingTask: {
					for (entry : clonedElements.entrySet) {
						if (entry.value == codeFragment.referencedViewField.resolveViewGUIElement) {		
							val newTask = copyElement(codeFragment) as UnmappingTask
							val newAbstractRef = factory.createAbstractViewGUIElementRef()
							newAbstractRef.ref = entry.key
							newTask.referencedViewField = newAbstractRef
							codeFragmentAction.addCodeFragmentToParentCodeContainer(newTask)
						}
					}
				}						
			}
		]
	}
	
	/**
	 * Add a CustomCodeFragment to a block of code.
	 * 
	 * Helper method to distinguish on whether a CustomCodeFragment is the direct child of a CustomAction or whether it is part of a
	 * ConditionalCodeFragment (if-else-conditions).
	 */
	def private static addCodeFragmentToParentCodeContainer(EObject codeFragmentContainer, CustomCodeFragment fragment) {
		switch (codeFragmentContainer) {
			CustomAction: {
				codeFragmentContainer.codeFragments.add(fragment)
			}
			IfCodeBlock: {
				codeFragmentContainer.codeFragments.add(fragment)
			}
			ElseCodeBlock: {
				codeFragmentContainer.codeFragments.add(fragment)
			}
		}
	}
	
	/**
	 * Look up pseudo-referenced ViewGUIElement
	 */
	def private static ViewGUIElement resolveAbstractViewGUIElementRef(ResourceSet input, AbstractViewGUIElementRef abstractRef, ViewGUIElement guiElem, HashMap<EObject, EObject> clonedElements) {
		var nextGuiElem = guiElem
		val qualifiedNameProvider = new DefaultDeclarativeQualifiedNameProvider()
		if (abstractRef.ref instanceof ViewGUIElement) {
			if (guiElem == null) {
				nextGuiElem = abstractRef.ref as ViewGUIElement
			} else {
				var qualifiedName = qualifiedNameProvider.getFullyQualifiedName(abstractRef.ref)
				for (searchName : qualifiedName.skipFirst(1).segments) {
					nextGuiElem = nextGuiElem.eAllContents.filter(typeof(ViewGUIElement)).findFirst(searchGuiElem | searchGuiElem.name != null && searchGuiElem.name.equals(searchName))
				}
			}
		} else if (abstractRef.ref instanceof ViewElementType || abstractRef.ref instanceof ContainerElementType) {
			if (guiElem == null) {
				nextGuiElem = abstractRef.ref.eContainer as ViewGUIElement
			}
			val searchName = switch (abstractRef.ref) {
				ViewElementRef: (abstractRef.ref as ViewElementRef).name
				ContainerElementRef: (abstractRef.ref as ContainerElementRef).name
			}
			nextGuiElem = nextGuiElem.eAllContents.filter(typeof(ViewGUIElement)).findFirst(searchGuiElem | searchGuiElem.name != null && searchGuiElem.name.equals(searchName))
		}
		if (nextGuiElem instanceof AutoGeneratedContentElement) {
			val parentGuiElem = nextGuiElem.eContainer.eContainer
			// Use initial mappings
			var Iterable<MappingTask> mappingTasks = getAutoGenAction(input).codeFragments.filter(typeof(MappingTask))
			if (abstractRef.path != null) {
				// ReferencedModelType
				mappingTasks = mappingTasks.toList.filter([it.pathDefinition.referencedAttribute == abstractRef.path.referencedAttribute])
			} else {
				// SimpleType
				mappingTasks = mappingTasks.toList.filter([it.pathDefinition.contentProviderRef.type instanceof SimpleType]).filter([(it.pathDefinition.contentProviderRef.type as SimpleType).type == abstractRef.simpleType.type])
			}
			val Collection<EObject> candidates = newArrayList
			mappingTasks.map([it.referencedViewField.ref]).forEach [ mappedGuiElem |
				candidates.add(mappedGuiElem)
				candidates.addAll(clonedElements.filter([key, value | value.equals(mappedGuiElem)]).keySet)
			]
			nextGuiElem = candidates?.findFirst(candidate | parentGuiElem.isAncestor(candidate)) as ViewGUIElement
		}
		if (abstractRef.getTail != null) {
			return resolveAbstractViewGUIElementRef(input, abstractRef.getTail(), nextGuiElem, clonedElements) 
		} else {
			return nextGuiElem;
		}
	}
	
}