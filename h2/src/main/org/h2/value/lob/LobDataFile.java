/*
 * Copyright 2004-2021 H2 Group. Multiple-Licensed under the MPL 2.0,
 * and the EPL 1.0 (https://h2database.com/html/license.html).
 * Initial Developer: H2 Group
 */
package org.h2.value.lob;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;

import org.h2.engine.Constants;
import org.h2.engine.SysProperties;
import org.h2.store.DataHandler;
import org.h2.store.FileStore;
import org.h2.store.FileStoreInputStream;
import org.h2.store.fs.FileUtils;
import org.h2.util.MathUtils;
import org.h2.value.ValueLob;

/**
 * LOB data stored in a temporary file.
 */
public final class LobDataFile extends LobData {

    private DataHandler handler;

    /**
     * If the LOB is a temporary LOB being managed by a temporary ResultSet, it
     * is stored in a temporary file.
     */
    private final String fileName;

    private final FileStore tempFile;

    public LobDataFile(DataHandler handler, String fileName, FileStore tempFile) {
        this.handler = handler;
        this.fileName = fileName;
        this.tempFile = tempFile;
    }

    public static String createTempLobFileName(DataHandler handler) throws IOException {
        String path = handler.getDatabasePath();
        if (path.isEmpty()) {
            path = SysProperties.PREFIX_TEMP_FILE;
        }
        return FileUtils.createTempFile(path, Constants.SUFFIX_TEMP_FILE, true);
    }

    /**
     * Remove the underlying resource, if any. For values that are kept fully in
     * memory this method has no effect.
     */
    @Override
    public void remove(ValueLob value) {
        if (fileName != null) {
            if (tempFile != null) {
                tempFile.stopAutoDelete();
            }
            // synchronize on the database, to avoid concurrent temp file
            // creation / deletion / backup
            synchronized (handler.getLobSyncObject()) {
                FileUtils.delete(fileName);
            }
        }
    }

    @Override
    public InputStream getInputStream(long precision) {
        FileStore store = handler.openFile(fileName, "r", true);
        boolean alwaysClose = SysProperties.lobCloseBetweenReads;
        return new BufferedInputStream(new FileStoreInputStream(store, handler, false, alwaysClose),
                Constants.IO_BUFFER_SIZE);
    }

    @Override
    public DataHandler getDataHandler() {
        return handler;
    }

    @Override
    public String toString() {
        return "lob-file: " + fileName;
    }

    public static int getBufferSize(DataHandler handler, long remaining) {
        if (remaining < 0 || remaining > Integer.MAX_VALUE) {
            remaining = Integer.MAX_VALUE;
        }
        int inplace = handler.getMaxLengthInplaceLob();
        long m = Constants.IO_BUFFER_SIZE;
        if (m < remaining && m <= inplace) {
            // using "1L" to force long arithmetic because
            // inplace could be Integer.MAX_VALUE
            m = Math.min(remaining, inplace + 1L);
            // the buffer size must be bigger than the inplace lob, otherwise we
            // can't know if it must be stored in-place or not
            m = MathUtils.roundUpLong(m, Constants.IO_BUFFER_SIZE);
        }
        m = Math.min(remaining, m);
        m = MathUtils.convertLongToInt(m);
        if (m < 0) {
            m = Integer.MAX_VALUE;
        }
        return (int) m;
    }

}
