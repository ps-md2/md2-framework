/*
* generated by Xtext
*/
package de.wwu.md2.framework.ui.labeling;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider;
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider;

import com.google.inject.Inject;

/**
 * Provides labels for a EObjects.
 * 
 * see http://www.eclipse.org/Xtext/documentation/latest/xtext.html#labelProvider
 */
public class MD2LabelProvider extends DefaultEObjectLabelProvider {

	@Inject
	public MD2LabelProvider(AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}


	//Labels and icons can be computed like this:
	
	public String text(Object ele) {
		Method getNameMethod;
		try {
			getNameMethod = ele.getClass().getMethod("getName");
			return (String) getNameMethod.invoke(ele) + " <"+ele.getClass().getInterfaces()[0].getSimpleName()+">";
		} catch (NoSuchMethodException | IllegalAccessException | IllegalArgumentException | InvocationTargetException e1) {
			return "<"+ele.getClass().getInterfaces()[0].getSimpleName()+">";
		}
	}
/*	
	//TODO: If you like to have pretty icons in the outline of the modeling IDE you can add them here.
    String image(MyModel ele) {
      return "MyModel.gif";
    }
*/
}
