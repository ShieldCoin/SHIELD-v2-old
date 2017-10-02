#include "ui_radio.h"
#include "guiutil.h"
#include "bitcoingui.h"
#include "util.h"
#include "main.h"
#include <QtCore>
#include <QtGui>
#if QT_VERSION >= 0x050000
#include <QtWebKit/QtWebKit>
#else
#include <QtWebKit>
#endif
#include <QtWidgets>
#include <QtWebKitWidgets/QtWebKitWidgets>

Radio::Radio(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::Radio),
    model(0)
{
    ui->setupUi(this);
}
    void Radio::setModel(WalletModel *model)
{
    this->model = model;
    if(!model)
        return;
}

Radio::~Radio()
{
    delete ui;
} 
