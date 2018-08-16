package org.nmrml.cv;

import com.sun.javafx.binding.StringFormatter;

/**
 * Created by ldpf on 25/01/17.
 */
public class Identifier {

    private static Identifier instance = null;
    private int id;

    protected Identifier() {
        this.id = 0;
    }

    public static Identifier getInstance() {
        if (instance == null) {
            instance = new Identifier();

        }
        return instance;
    }

    public String nextId() {
        id++;
        return String.format("ID%05d", id);
    }


}
