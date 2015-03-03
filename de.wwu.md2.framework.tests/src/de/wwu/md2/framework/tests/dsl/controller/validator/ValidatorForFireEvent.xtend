package de.wwu.md2.framework.tests.dsl.controller.validator

import org.eclipse.xtext.junit4.InjectWith
import de.wwu.md2.framework.MD2InjectorProvider
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.XtextRunner
import javax.inject.Inject
import org.eclipse.xtext.junit4.util.ParseHelper
import de.wwu.md2.framework.mD2.MD2Model
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.junit.Before
import static extension de.wwu.md2.framework.tests.utils.ModelProvider.*

import org.junit.Test
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import de.wwu.md2.framework.validation.ControllerValidator
import de.wwu.md2.framework.mD2.MD2Package

@InjectWith(typeof(MD2InjectorProvider))
@RunWith(typeof(XtextRunner))
class ValidatorForFireEvent {
	
	@Inject extension ParseHelper<MD2Model>
	@Inject extension ValidationTestHelper
	MD2Model fireEventValidationCModel;
	MD2Model fireEventValidationMModel;
	MD2Model fireEventValidationVModel;
	ResourceSet rs;
	
	@Before
	def void setUp() {
		rs = new ResourceSetImpl();
		fireEventValidationCModel = FIRE_EVENT_VAL_C.load.parse(rs);
		fireEventValidationMModel = FIRE_EVENT_VAL_M.load.parse(rs);
		fireEventValidationVModel = FIRE_EVENT_VAL_V.load.parse(rs);
	}
	
	@Test
	def checkMultipleFireEventValidator(){
		fireEventValidationCModel.assertWarning(MD2Package::eINSTANCE.customAction, ControllerValidator::MULTIPLEFIREEVENTS);
	}
	
	@Test
	def checkSaveBeforeFireEventValidator(){
		fireEventValidationCModel.assertWarning(MD2Package::eINSTANCE.fireEventAction, ControllerValidator::SAVEBEFOREFIREEVENT);
	}	
}